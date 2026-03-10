#!/bin/bash
# ==========================================================
# 0. SETUP & WARNA
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
echo -e "${CYAN}${BOLD} SETANG TUYUL TOOLS - V14.15 (GILA MODE) ${NC}"
echo -e "${CYAN}${BOLD} Dynamic Smooth Resolution | Realme Only ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo ""
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit 1;
fi
# ==========================================================
# MENU PILIHAN
# ==========================================================
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}>>> PILIH MODE OPERASI${NC}"
echo -e "${CYAN}==============================================${NC}"
echo -e "1. ${RED}ZERO TOLERANCE IP${NC} → IP tidak boleh dipakai ulang"
echo -e "2. ${GREEN}NO IP LIMIT${NC} → Boleh pakai IP sama berulang"
echo ""
read -p "Masukkan pilihan (1 atau 2): " MODE_CHOICE
if [ "$MODE_CHOICE" == "1" ]; then
    MODE="ZERO_TOLERANCE"
    IP_HISTORY="/root/used_ips_setang.txt"
    if [ ! -f "$IP_HISTORY" ]; then touch "$IP_HISTORY"; fi
    echo -e "${RED}>>> MODE AKTIF: ZERO TOLERANCE IP${NC}"
elif [ "$MODE_CHOICE" == "2" ]; then
    MODE="NO_LIMIT"
    IP_HISTORY=""
    echo -e "${GREEN}>>> MODE AKTIF: NO IP LIMIT${NC}"
else
    echo -e "${RED}Pilihan tidak valid!${NC}"
    exit 1
fi

# ==========================================================
# RESOLUSI LAYAR SMOOTH (BARU - BEBAS BERAPA AJA)
# ==========================================================
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}>>> PILIH RESOLUSI LAYAR SMOOTH${NC}"
echo -e "${CYAN}==============================================${NC}"
echo -e "1. ${GREEN}720x1600 @320dpi${NC} → Ringan & Super Smooth"
echo -e "2. ${GREEN}1080x2400 @480dpi${NC} → Balanced Ultra Smooth"
echo -e "3. ${GREEN}1440x3120 @560dpi${NC} → Ultra Realistic Gila"
echo -e "4. ${YELLOW}CUSTOM${NC} → Bebas berapa aja (masukkan manual)"
echo ""
read -p "Masukkan pilihan (1-4): " RES_CHOICE
case $RES_CHOICE in
    1)
        WIDTH=720
        HEIGHT=1600
        DPI=320
        ;;
    2)
        WIDTH=1080
        HEIGHT=2400
        DPI=480
        ;;
    3)
        WIDTH=1440
        HEIGHT=3120
        DPI=560
        ;;
    4)
        read -p "Masukkan WIDTH (contoh: 1440): " WIDTH
        read -p "Masukkan HEIGHT (contoh: 3120): " HEIGHT
        read -p "Masukkan DPI (contoh: 560): " DPI
        ;;
    *)
        echo -e "${RED}Pilihan tidak valid! Pakai default 720x1600@320dpi${NC}"
        WIDTH=720
        HEIGHT=1600
        DPI=320
        ;;
esac
echo -e "${GREEN}>>> RESOLUSI AKTIF: ${WIDTH}x${HEIGHT} @${DPI}dpi (Smooth Mode)${NC}"

# ==========================================================
# 1. SETUP LOGGING
# ==========================================================
NEW_HISTORY="/root/used_devices_setang.txt"
if [ ! -f "$NEW_HISTORY" ]; then touch "$NEW_HISTORY"; fi
HISTORY_FILE="$NEW_HISTORY"
echo -e "${GREEN}>>> Device Log : $HISTORY_FILE${NC}"
if [ "$MODE" == "ZERO_TOLERANCE" ]; then
    echo -e "${GREEN}>>> IP Log : $IP_HISTORY${NC}"
fi
# ==========================================================
# 2-4. SWAP, DRIVER, CLEAN (LOG DITAMPILKAN FULL)
# ==========================================================
SWAP_FILE="/swapfile"
if [ ! -f "$SWAP_FILE" ]; then
    echo -e "${YELLOW}>>> [SYSTEM] Membuat Safety Swap 4GB...${NC}"
    fallocate -l 4G $SWAP_FILE; chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    if ! grep -q "$SWAP_FILE" /etc/fstab; then echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab; fi
fi
sysctl vm.swappiness=10
if ! lsmod | grep -q binder_linux; then
    modprobe binder_linux devices="binder,hwbinder,vndbinder"
    modprobe ashmem_linux
    if ! lsmod | grep -q binder_linux; then
        echo -e "${YELLOW}>>> [SYSTEM] Auto-Repair Driver...${NC}"
        apt-get update -y
        apt-get install -y linux-modules-extra-$(uname -r) linux-tools-common linux-tools-generic linux-tools-$(uname -r)
        modprobe binder_linux devices="binder,hwbinder,vndbinder"
        modprobe ashmem_linux
    fi
else
    echo -e "${GREEN}>>> [SYSTEM] Driver Ready.${NC}"
fi
if ! command -v docker &> /dev/null || ! command -v adb &> /dev/null; then
    echo -e "${YELLOW}>>> [INSTALL] Docker & ADB...${NC}"
    apt-get update -y
    apt-get install -y docker.io android-tools-adb curl unzip dos2unix coreutils
    systemctl start docker; systemctl enable docker
fi
echo -e "${YELLOW}>>> [CLEAN] Memastikan Container Mati...${NC}"
docker rm -f android_11
rm -rf ~/data_11; mkdir -p ~/data_11
# ==========================================================
# 5. REALISTIC GILA GENERATOR (Ultra + Pro Max + Neo 7 SE + dll)
# ==========================================================
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}>>> SETANG TUYUL-TOOLS (V14.15 - GILA MODE)${NC}"
echo -e "${CYAN}>>> Dynamic Smooth Resolution + Varian Super Lengkap${NC}"
echo -e "${CYAN}==============================================${NC}"
BRAND="realme"
MANUF="realme"
# Varian Gila
GT_PREFIX=("GT " "GT Neo " "GT Master " "GT Explorer " "GT Racing ")
GT_NUMS=(2 3 5 6 7 8)
C_NUMS=(11 12 15 21 25 30 31 33 35 51 53 55 57 61 63 65 67 71 73 75 81 83 85)
NARZO_NUMS=(20 30 50 60 70 80 90)
NUM_BASE=(8 9 10 11 12 13 14 15 16)
NOTE_NUMS=(50 60 70 80 90)
# Varian Super Gila (bisa ditambahkan di belakang)
EXTRA=(" " " Pro" " Pro+" " Pro Max" " Ultra" " 5G" " Lite" " Turbo" " SE" " Neo" " Neo SE"
       " Master Edition" " Racing Edition" " Legend" " Explorer" " Prime" "x" "T" " 5G Ultra" " Turbo 5G")
echo -e "${YELLOW}>>> [GENERATE] Mencari Identitas Super Realistis & Gila...${NC}"
while true; do
    RAND_TYPE=$((RANDOM % 6))
    case $RAND_TYPE in
        0) # C Series Gila
            NUM=${C_NUMS[$RANDOM % ${#C_NUMS[@]}]}
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme C${NUM}${SUFFIX}"
            ;;
        1) # GT Series Super Gila
            PREFIX=${GT_PREFIX[$RANDOM % ${#GT_PREFIX[@]}]}
            NUM=${GT_NUMS[$RANDOM % ${#GT_NUMS[@]}]}
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme ${PREFIX}${NUM}${SUFFIX}"
            ;;
        2) # Narzo Gila
            NUM=${NARZO_NUMS[$RANDOM % ${#NARZO_NUMS[@]}]}
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme Narzo ${NUM}${SUFFIX}"
            ;;
        3) # Number Series
            NUM=${NUM_BASE[$RANDOM % ${#NUM_BASE[@]}]}
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme ${NUM}${SUFFIX}"
            ;;
        4) # Note Series
            NUM=${NOTE_NUMS[$RANDOM % ${#NOTE_NUMS[@]}]}
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme Note ${NUM}${SUFFIX}"
            ;;
        5) # P Series
            NUM=$((RANDOM % 5 + 1))
            SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}
            MARKETING_NAME="Realme P${NUM}${SUFFIX}"
            ;;
    esac
    RAND_RMX="RMX$((RANDOM % 4000 + 1000))"
    REAL_MODEL="$RAND_RMX"
  
    GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
    GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    if ! grep -qE "$MARKETING_NAME|$REAL_MODEL|$GEN_IMEI|$GEN_MAC|$GEN_SERIAL" "$HISTORY_FILE"; then
        break
    fi
done
RAND_AND_VER=("9" "10" "11" "12" "13" "14")
RAND_AND_VER=${RAND_AND_VER[$RANDOM % ${#RAND_AND_VER[@]}]}
RAND_BUILD="TP1A.$((RANDOM % 900000 + 100000)).001"
RAND_TIME=$((RANDOM % 200000000 + 1550000000))
FINGERPRINT="${BRAND}/${REAL_MODEL}/${REAL_MODEL}:${RAND_AND_VER}/${RAND_BUILD}/${RAND_TIME}:user/release-keys"
CHIPSETS=(
    "mt6765|MediaTek|Helio P35" "mt6762|MediaTek|Helio P22" "mt6771|MediaTek|Helio P60" "mt6769|MediaTek|Helio G85"
    "bengal|Qualcomm|Snapdragon 665" "atoll|Qualcomm|Snapdragon 720G" "lito|Qualcomm|Snapdragon 765G" "kona|Qualcomm|Snapdragon 865"
    "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1" "mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900"
)
RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"
# ==========================================================
# 6. SIM & IP
# ==========================================================
RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"
MY_IP=$(curl -s ifconfig.me || echo "Offline")
if [ "$MODE" == "ZERO_TOLERANCE" ]; then
    if grep -Fxq "$MY_IP" "$IP_HISTORY"; then
        echo -e "${RED}${BOLD}[BAHAYA] IP INI ($MY_IP) SUDAH TERPAKAI!${NC}"
        echo -e "${YELLOW}Ganti IP dulu!${NC}"
        exit 1
    else
        echo "$MY_IP" >> "$IP_HISTORY"
        echo -e "${GREEN}[OK] IP Aman (Zero Tolerance).${NC}"
    fi
else
    echo -e "${GREEN}[OK] IP Aman (No Limit).${NC}"
fi
echo -e "${BLUE}>>> NEW IDENTITY (SUPER GILA & REALISTIS):${NC}"
echo -e "Brand : ${BOLD}$BRAND${NC}"
echo -e "Device Name : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code : ${BOLD}$REAL_MODEL${NC}"
echo -e "Fake SOC : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
echo -e "Resolution : ${BOLD}${WIDTH}x${HEIGHT} @${DPI}dpi${NC}"
echo -e "IMEI : ${BOLD}$GEN_IMEI${NC}"
echo -e "MAC Address : ${BOLD}$GEN_MAC${NC}"
echo -e "Phone Number : ${BOLD}$GEN_PHONE${NC}"
echo -e "IP Address : ${BOLD}$MY_IP${NC}"
# ==========================================================
# 7. START CONTAINER — RESOLUSI DINAMIS SMOOTH
# ==========================================================
MAX_RETRIES=5
RETRY_COUNT=0
echo -e "${YELLOW}>>> [STARTING] Android 11 (16GB RAM - ${WIDTH}x${HEIGHT} @${DPI}dpi)...${NC}"
docker rm -f android_11
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    sudo docker run -itd --memory-swap="-1" --privileged --restart=always \
        --shm-size=2g -v ~/data_11:/data -p 5555:5555 --name android_11 \
        redroid/redroid:11.0.0-latest \
        androidboot.redroid_width=${WIDTH} androidboot.redroid_height=${HEIGHT} androidboot.redroid_dpi=${DPI} \
        androidboot.redroid_gpu_mode=guest \
        androidboot.redroid_mac=$GEN_MAC androidboot.serialno=$GEN_SERIAL \
        ro.product.brand=$BRAND ro.product.manufacturer=$MANUF \
        ro.product.model=$REAL_MODEL ro.product.name=$REAL_MODEL \
        ro.product.device=$REAL_MODEL ro.product.board=$CHIP_BOARD \
        ro.board.platform=$CHIP_BOARD ro.soc.manufacturer=$CHIP_MANUF \
        ro.soc.model="$CHIP_MODEL" ro.build.fingerprint=$FINGERPRINT \
        ro.ril.oem.imei=$GEN_IMEI ro.ril.oem.phone_number=$GEN_PHONE \
        gsm.sim.msisdn=$GEN_PHONE ro.adb.secure=0 ro.secure=0 ro.debuggable=1 \
        ro.config.low_ram=false debug.sf.nobootanimation=1 \
        debug.sf.disable_hwc=1 dalvik.vm.heapstartsize=32m \
        dalvik.vm.heapgrowthlimit=512m dalvik.vm.heapsize=2048m \
        ro.sys.fw.bg_apps_limit=128
    sleep 2
    sudo docker exec android_11 rm -f /data/misc/adb/adb_keys
    sudo docker exec android_11 killall adbd
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
        echo -e "${GREEN}${BOLD}>>> [OK] SYSTEM READY! (${WIDTH}x${HEIGHT} @${DPI}dpi)${NC}"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo -e "${RED}>>> [TIMEOUT] Restarting...${NC}"
        docker rm -f android_11
        sleep 2
    fi
done
if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}[FATAL] Gagal Booting.${NC}"
    exit 1
fi
echo "BRAND=$BRAND | NAME=$MARKETING_NAME | MODEL=$REAL_MODEL | IMEI=$GEN_IMEI | SN=$GEN_SERIAL | MAC=$GEN_MAC | RES=${WIDTH}x${HEIGHT}@${DPI}" >> "$HISTORY_FILE"
# ==========================================================
# 8-9. INJECT & INSTALL DUKU
# ==========================================================
echo -e "${GREEN}>>> [INJECT] SIM & Disable Animations...${NC}"
adb -s localhost:5555 wait-for-device
adb -s localhost:5555 shell settings put global window_animation_scale 0
adb -s localhost:5555 shell settings put global transition_animation_scale 0
adb -s localhost:5555 shell settings put global animator_duration_scale 0
adb -s localhost:5555 shell settings put global device_name \"$MARKETING_NAME\"
adb -s localhost:5555 shell setprop gsm.sim.operator.alpha "Telkomsel"
adb -s localhost:5555 shell setprop gsm.sim.operator.numeric "51010"
adb -s localhost:5555 shell setprop gsm.sim.state "READY"
adb -s localhost:5555 shell setprop gsm.current.phone-number "$GEN_PHONE"
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"
sleep 2
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.2/dukulive1770365885.apk"
DUKU_PATH="/root/duku.apk"
if [ ! -f "$DUKU_PATH" ]; then
    echo -e "${YELLOW}>>> [DOWNLOAD] Duku APK...${NC}"
    curl -L -o "$DUKU_PATH" "$DUKU_URL"
fi
if [ -f "$DUKU_PATH" ]; then
    echo -e "${GREEN}>>> [INSTALL] Duku Live...${NC}"
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH"
    PKG_NAME=$(adb -s localhost:5555 shell pm list packages -3 | awk -F: '{print $2}' | head -n 1)
    if [ ! -z "$PKG_NAME" ]; then
        adb -s localhost:5555 shell dumpsys deviceidle disable $PKG_NAME
        adb -s localhost:5555 shell cmd appops set $PKG_NAME RUN_IN_BACKGROUND allow
        echo -e "${GREEN}${BOLD}>>> [SUKSES] Duku Optimized!${NC}"
    fi
fi
echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}${BOLD}✅ SELESAI! Resolusi ${WIDTH}x${HEIGHT} @${DPI}dpi + Varian Gila aktif${NC}"
echo -e "${CYAN}==============================================${NC}"
