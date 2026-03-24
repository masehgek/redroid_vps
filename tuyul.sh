#!/bin/bash
# ==========================================================
# SETANG TUYUL TOOLS - V14.15 (PURE ZERO TOLERANCE)
# RESOLUTION: 720x1600 @320dpi | FULL AUTO
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
echo -e "${CYAN}${BOLD} SETANG TUYUL TOOLS - V14.15 (ZERO TOLERANCE) ${NC}"
echo -e "${CYAN}${BOLD} Oracle ARM 24GB + Smart Wait + Duku VIP Launch ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit 1;
fi

# ==========================================================
# 1. FIXED CONFIGURATION
# ==========================================================
MODE="ZERO_TOLERANCE"
IP_HISTORY="/root/used_ips_setang.txt"
NEW_HISTORY="/root/used_devices_setang.txt"
if [ ! -f "$IP_HISTORY" ]; then touch "$IP_HISTORY"; fi
if [ ! -f "$NEW_HISTORY" ]; then touch "$NEW_HISTORY"; fi

WIDTH=720; HEIGHT=1600; DPI=320

echo -e "${RED}>>> MODE AKTIF      : ZERO TOLERANCE IP${NC}"
echo -e "${GREEN}>>> RESOLUSI AKTIF  : 720x1600 @320dpi (Smooth Mode)${NC}"

# ==========================================================
# 2. IP CHECK (ZERO TOLERANCE)
# ==========================================================
MY_IP=$(curl -s ifconfig.me || echo "Offline")
if grep -Fxq "$MY_IP" "$IP_HISTORY"; then
    echo -e "${RED}${BOLD}[BAHAYA] IP INI ($MY_IP) SUDAH TERPAKAI!${NC}"
    echo -e "${YELLOW}Ganti IP/VPN/Proxy Anda dulu! Container batal dibuat.${NC}"
    exit 1
else
    echo "$MY_IP" >> "$IP_HISTORY"
    echo -e "${GREEN}[OK] IP Aman (Zero Tolerance).${NC}"
fi

# ==========================================================
# 3. SWAP & DRIVER CHECK
# ==========================================================
SWAP_FILE="/swapfile"
if [ ! -f "$SWAP_FILE" ]; then
    echo -e "${YELLOW}>>> [SYSTEM] Membuat Safety Swap 4GB...${NC}"
    fallocate -l 4G $SWAP_FILE; chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE; swapon $SWAP_FILE
    if ! grep -q "$SWAP_FILE" /etc/fstab; then echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab; fi
fi
sysctl vm.swappiness=10

if ! lsmod | grep -q binder_linux; then
    modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null || true
fi

apt-get update -y >/dev/null 2>&1
apt-get install -y adb curl unzip >/dev/null 2>&1
systemctl start docker 2>/dev/null || true

# ==========================================================
# 4. DEEP IDENTITY GENERATOR
# ==========================================================
BRAND="realme"
MANUF="realme"
GT_PREFIX=("GT " "GT Neo " "GT Master " "GT Explorer " "GT Racing ")
GT_NUMS=(2 3 5 6 7 8)
C_NUMS=(11 12 15 21 25 30 31 33 35 51 53 55 57 61 63 65 67 71 73 75 81 83 85)
EXTRA=(" " " Pro" " Pro+" " Ultra" " 5G" " Lite" " Turbo" " SE" " Neo")

echo -e "${YELLOW}>>> [GENERATE] Mencari Identitas Super Realistis & Gila...${NC}"
while true; do
    RAND_TYPE=$((RANDOM % 3))
    case $RAND_TYPE in
        0) NUM=${C_NUMS[$RANDOM % ${#C_NUMS[@]}]}; SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}; MARKETING_NAME="Realme C${NUM}${SUFFIX}" ;;
        1) PREFIX=${GT_PREFIX[$RANDOM % ${#GT_PREFIX[@]}]}; NUM=${GT_NUMS[$RANDOM % ${#GT_NUMS[@]}]}; SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}; MARKETING_NAME="Realme ${PREFIX}${NUM}${SUFFIX}" ;;
        2) NUM=$((RANDOM % 10 + 5)); SUFFIX=${EXTRA[$RANDOM % ${#EXTRA[@]}]}; MARKETING_NAME="Realme Narzo ${NUM}0${SUFFIX}" ;;
    esac
    REAL_MODEL="RMX$((RANDOM % 4000 + 1000))"
    GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
    GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    if ! grep -qE "$GEN_IMEI|$GEN_MAC|$GEN_SERIAL" "$NEW_HISTORY"; then break; fi
done

RAND_BUILD="RP1A.$((RANDOM % 900000 + 100000)).001"
FINGERPRINT="${BRAND}/${REAL_MODEL}/${REAL_MODEL}:11/${RAND_BUILD}/$((RANDOM % 200000000 + 1550000000)):user/release-keys"

CHIPSETS=("mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900" "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1")
RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"

RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"

echo "BRAND=$BRAND | NAME=$MARKETING_NAME | MODEL=$REAL_MODEL | IMEI=$GEN_IMEI | MAC=$GEN_MAC | SERIAL=$GEN_SERIAL | SOC=$CHIP_MODEL" >> "$NEW_HISTORY"

# Menampilkan informasi identitas ke layar
echo -e "${BLUE}>>> NEW IDENTITY (SUPER GILA & REALISTIS):${NC}"
echo -e "Brand : ${BOLD}$BRAND${NC}"
echo -e "Device Name : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code : ${BOLD}$REAL_MODEL${NC}"
echo -e "Fake SOC : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
echo -e "Resolution : ${BOLD}${WIDTH}x${HEIGHT} @${DPI}dpi${NC}"
echo -e "IMEI : ${BOLD}$GEN_IMEI${NC}"
echo -e "Serial Number : ${BOLD}$GEN_SERIAL${NC}"
echo -e "MAC Address : ${BOLD}$GEN_MAC${NC}"
echo -e "Phone Number : ${BOLD}$GEN_PHONE${NC}"
echo -e "IP Address : ${BOLD}$MY_IP${NC}"

# ==========================================================
# 5. START CONTAINER (WITH FULL BYPASS PROPERTIES)
# ==========================================================
docker rm -f android_11 2>/dev/null || true
rm -rf ~/data_11; mkdir -p ~/data_11

echo -e "${YELLOW}>>> [STARTING] Android 11 (Safe Limits - 720x1600 @320dpi)...${NC}"
docker run -itd --memory-swap="-1" --privileged --restart=always \
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

sleep 3

# ==========================================================
# 6. SMART WAIT & INJECT SIM
# ==========================================================
echo -ne "${YELLOW}>>> [WAIT] Smart Boot Check: ${NC}"
for (( c=1; c<=60; c++ )); do
    adb connect localhost:5555 >/dev/null 2>&1
    STATUS=$(adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$STATUS" == "1" ]; then
        echo -e "\n${GREEN}${BOLD}>>> [OK] SYSTEM READY! (Booting: $c detik)${NC}"
        break
    fi
    echo -ne "${CYAN}■${NC}"; sleep 1
done

echo -e "${GREEN}>>> [INJECT] SIM Telkomsel & Disable Animations...${NC}"
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

# ==========================================================
# 7. INSTALL DUKU & VIP AUTO-LAUNCH
# ==========================================================
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.3/dukulive1773539296.apk"
DUKU_PATH="/root/duku.apk"
if [ ! -f "$DUKU_PATH" ]; then
    echo -e "${YELLOW}>>> [DOWNLOAD] Duku APK...${NC}"
    curl -L -o "$DUKU_PATH" "$DUKU_URL"
fi

if [ -f "$DUKU_PATH" ]; then
    echo -e "${GREEN}>>> [INSTALL] Memasang Duku Live...${NC}"
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH" >/dev/null 2>&1
    
    echo -e "${YELLOW}>>> [LAUNCH] Membuka Duku Live via SplashActivity...${NC}"
    adb -s localhost:5555 shell am start -n "com.duku666.live/com.duku666.live.activity.SplashActivity" >/dev/null 2>&1
fi

echo -e "${CYAN}==============================================${NC}"
echo -e "${GREEN}${BOLD}✅ SELESAI! Resolusi 720x1600 @320dpi + Anti-Deteksi Aktif${NC}"
echo -e "${CYAN}==============================================${NC}"
