#!/bin/bash

# ==========================================================
#   0. SETUP & WARNA
# ==========================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo -e "${CYAN}${BOLD}     SETANG TUYUL TOOLS - V14.15 (SINGLE DEVICE)   ${NC}"
echo -e "${CYAN}${BOLD}               INFINITE RUN | 24GB                 ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit; fi

# Variable Init
MAX_RETRIES=5
RETRY_COUNT=0

# ==========================================================
#   1. SWAP SAFETY (4GB)
# ==========================================================
SWAP_FILE="/swapfile"
if [ ! -f "$SWAP_FILE" ]; then
    echo -e "${YELLOW}>>> [SYSTEM] Membuat Safety Swap 4GB...${NC}"
    fallocate -l 4G $SWAP_FILE; chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE >/dev/null 2>&1; swapon $SWAP_FILE
    if ! grep -q "$SWAP_FILE" /etc/fstab; then echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab; fi
fi
sysctl vm.swappiness=10 >/dev/null

# ==========================================================
#   2. SMART DRIVER CHECK & INSTALL TOOLS
# ==========================================================
if ! lsmod | grep -q binder_linux; then
    modprobe binder_linux devices="binder,hwbinder,vndbinder" >/dev/null 2>&1
    modprobe ashmem_linux >/dev/null 2>&1
    
    if ! lsmod | grep -q binder_linux; then
        echo -e "${YELLOW}>>> [SYSTEM] Auto-Repair Driver (Fresh Install)...${NC}"
        apt-get update -y
        apt-get install -y linux-modules-extra-$(uname -r) linux-tools-common linux-tools-generic linux-tools-$(uname -r)
        modprobe binder_linux devices="binder,hwbinder,vndbinder"
        modprobe ashmem_linux
    else
        echo -e "${GREEN}>>> [SYSTEM] Driver Recovered.${NC}"
    fi
else
    echo -e "${GREEN}>>> [SYSTEM] Driver Ready.${NC}"
fi

if ! command -v docker &> /dev/null || ! command -v adb &> /dev/null; then
    echo -e "${YELLOW}>>> [INSTALL] Docker & ADB Sedang Diinstall, Mohon Tunggu...${NC}"
    apt-get update -y
    apt-get install -y docker.io android-tools-adb curl unzip dos2unix coreutils
    systemctl start docker; systemctl enable docker
fi

# ==========================================================
#   3. CLEAN UP (HARD KILL)
# ==========================================================
echo -e "${YELLOW}>>> [CLEAN] Memastikan Container Mati...${NC}"
docker rm -f android_11 >/dev/null 2>&1
rm -rf ~/data_11; mkdir -p ~/data_11

# ==========================================================
#   4. DATABASE & DEVICE IDENTITY
# ==========================================================
# Gunakan 1 Device secara spesifik
DEVICE_DATA="realme|realme|Realme 10 Pro+|realme/RMX3686/RMX3686:13/TP1A.220905.001/1683882294:user/release-keys"
IFS='|' read -r BRAND MANUF MARKETING_NAME FINGERPRINT <<< "$DEVICE_DATA"
REAL_MODEL=$(echo "$FINGERPRINT" | cut -d'/' -f2)

CHIPSETS=(
    "mt6765|MediaTek|Helio P35" "mt6762|MediaTek|Helio P22" "mt6771|MediaTek|Helio P60" "mt6769|MediaTek|Helio G85"
    "bengal|Qualcomm|Snapdragon 665" "atoll|Qualcomm|Snapdragon 720G" "lito|Qualcomm|Snapdragon 765G" "kona|Qualcomm|Snapdragon 865"
    "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1" "mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900"
)
RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"

# Randomize SIM & MAC
GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"
GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MY_IP=$(curl -s ifconfig.me || echo "Offline")

echo -e "${BLUE}>>> IDENTITY DETAILS:${NC}"
echo -e "Brand        : ${BOLD}$BRAND${NC}"
echo -e "Device Name  : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code   : ${BOLD}$REAL_MODEL${NC}"
echo -e "Fake SOC     : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
echo -e "IP           : ${BOLD}$MY_IP${NC}"

# ==========================================================
#   5. START CONTAINER (AUTO CPU)
# ==========================================================
echo -e "${YELLOW}>>> [STARTING] Android 11 (16GB Physical RAM - Auto CPU)...${NC}"

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    
    # Start Docker
    sudo docker run -itd --memory="16g" --memory-swap="-1" --privileged --restart=always \
        --shm-size=2g \
        -v ~/data_11:/data -p 5555:5555 --name android_11 \
        redroid/redroid:11.0.0-latest \
        androidboot.redroid_width=720 androidboot.redroid_height=1280 androidboot.redroid_dpi=320 \
        androidboot.redroid_gpu_mode=guest \
        androidboot.redroid_mac=$GEN_MAC androidboot.serialno=$GEN_SERIAL \
        ro.product.brand=$BRAND \
        ro.product.manufacturer=$MANUF \
        ro.product.model=$REAL_MODEL \
        ro.product.name=$REAL_MODEL \
        ro.product.device=$REAL_MODEL \
        ro.product.board=$CHIP_BOARD \
        ro.board.platform=$CHIP_BOARD \
        ro.soc.manufacturer=$CHIP_MANUF \
        ro.soc.model="$CHIP_MODEL" \
        ro.build.fingerprint=$FINGERPRINT \
        ro.ril.oem.imei=$GEN_IMEI \
        ro.ril.oem.phone_number=$GEN_PHONE \
        gsm.sim.msisdn=$GEN_PHONE \
        ro.adb.secure=0 ro.secure=0 ro.debuggable=1 \
        ro.config.low_ram=false \
        debug.sf.nobootanimation=1 \
        debug.sf.disable_hwc=1 \
        dalvik.vm.heapstartsize=32m \
        dalvik.vm.heapgrowthlimit=512m \
        dalvik.vm.heapsize=2048m \
        ro.sys.fw.bg_apps_limit=128 > /dev/null

    # Remove keys & restart adb
    sleep 2; sudo docker exec android_11 rm -f /data/misc/adb/adb_keys; sudo docker exec android_11 killall adbd

    # Fast check boot (Watchdog)
    echo -e "${YELLOW}>>> [WAIT] Cek Booting (Max 15s)...${NC}"
    
    BOOT_SUCCESS="false"
    for (( c=1; c<=15; c++ )); do
        adb connect localhost:5555 >/dev/null 2>&1
        STATUS=$(adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
        if [ "$STATUS" == "1" ]; then
            BOOT_SUCCESS="true"
            break
        fi
        sleep 1
    done

    if [ "$BOOT_SUCCESS" == "true" ]; then
        echo -e "${GREEN}${BOLD}>>> [OK] SYSTEM READY! (Attempt $((RETRY_COUNT+1)))${NC}"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo -e "${RED}>>> [TIMEOUT] Boot Stuck. Restarting Container (Retry $RETRY_COUNT/$MAX_RETRIES)...${NC}"
        docker rm -f android_11 >/dev/null 2>&1
        sleep 2
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}[FATAL] Gagal Booting setelah $MAX_RETRIES kali percobaan.${NC}"
    exit 1
fi

# ==========================================================
#   6. INJECT SIM & NO ANIMATION
# ==========================================================
echo -e "${GREEN}>>> [INJECT] SIM & Disable Animations...${NC}"
adb -s localhost:5555 wait-for-device

# Matikan Animasi
adb -s localhost:5555 shell settings put global window_animation_scale 0
adb -s localhost:5555 shell settings put global transition_animation_scale 0
adb -s localhost:5555 shell settings put global animator_duration_scale 0

# Settings Inject
adb -s localhost:5555 shell settings put global device_name \"$MARKETING_NAME\"
adb -s localhost:5555 shell setprop gsm.sim.operator.alpha "Telkomsel"
adb -s localhost:5555 shell setprop gsm.sim.operator.numeric "51010"
adb -s localhost:5555 shell setprop gsm.sim.state "READY"
adb -s localhost:5555 shell setprop gsm.current.phone-number "$GEN_PHONE"
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"
adb -s localhost:5555 shell "pkill -f com.android.phone || killall com.android.phone"
adb -s localhost:5555 shell "killall rild" >/dev/null 2>&1

echo -e "${YELLOW}>>> [REFRESH] Signal...${NC}"
sleep 2
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"

# ==========================================================
#   7. INSTALL APK & AUTO-OPTIMIZE
# ==========================================================
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.2/dukulive1770365885.apk"
DUKU_PATH="/root/duku.apk"

if [ ! -f "$DUKU_PATH" ]; then echo -e "${YELLOW}>>> [DOWNLOAD] Duku APK Sedang Diunduh...${NC}"; curl -L -o "$DUKU_PATH" "$DUKU_URL"; fi
if [ -f "$DUKU_PATH" ]; then
    echo -e "${GREEN}>>> [INSTALL] Memasang Duku Live ke Emulator...${NC}"
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH"
    
    # Auto Optimize
    echo -e "${BLUE}>>> [OPTIMIZE] Mencegah Force Close pada APK...${NC}"
    PKG_NAME=$(adb -s localhost:5555 shell pm list packages -3 | awk -F: '{print $2}' | head -n 1)
    
    if [ ! -z "$PKG_NAME" ]; then
        echo -e "${CYAN}>>> Target Package: $PKG_NAME${NC}"
        adb -s localhost:5555 shell dumpsys deviceidle disable $PKG_NAME >/dev/null 2>&1
        adb -s localhost:5555 shell cmd appops set $PKG_NAME RUN_IN_BACKGROUND allow >/dev/null 2>&1
        echo -e "${GREEN}${BOLD}>>> [SUKSES] APK Terpasang & Optimized!${NC}"
    else
        echo -e "${RED}>>> [WARN] Nama paket tidak ditemukan. Instalasi mungkin gagal.${NC}"
    fi
fi
echo -e "${CYAN}==============================================${NC}"
