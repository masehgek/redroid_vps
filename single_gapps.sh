#!/bin/bash
# ==========================================================
# SETANG TUYUL TOOLS - SINGLE EDITION (ANDROID 11 + GAPPS)
# Auto Build Image | Chaos Identity | Auto Bypass Black Screen
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
echo -e "${CYAN}${BOLD}  SETANG TUYUL TOOLS - SINGLE INSTANCE (ANDROID 11)   ${NC}"
echo -e "${CYAN}${BOLD}  Fitur: Auto-Build Play Store (GApps ARM64) + Bypass ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"

if [ "$EUID" -ne 0 ]; then echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit 1; fi

apt-get update -y >/dev/null 2>&1
apt-get install -y docker.io adb curl unzip wget iptables-persistent netfilter-persistent >/dev/null 2>&1
systemctl start docker 2>/dev/null || true

# Buka Port 5555
iptables -I INPUT -p tcp -m tcp --dport 5555 -j ACCEPT
netfilter-persistent save >/dev/null 2>&1

# ==========================================================
# 1. AUTO BUILD CUSTOM IMAGE (Hanya 1x jalan)
# ==========================================================
IMAGE_NAME="redroid11_gapps"
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo -e "\n${YELLOW}>>> [SYSTEM] Custom Image belum ada. Memulai Perakitan Android 11 + GApps...${NC}"
    echo -e "${YELLOW}>>> Mengunduh MindTheGapps (Tunggu sebentar, ukuran file lumayan besar)...${NC}"
    
    mkdir -p /root/redroid-build && cd /root/redroid-build
    wget -q --show-progress https://archive.org/download/mindthegapps-archive/MindTheGapps-11.0.0-arm64-20230922_081122.zip -O gapps.zip
    
    echo -e "${YELLOW}>>> Mengekstrak file dan merakit Docker Image...${NC}"
    unzip -q gapps.zip
    cat <<EOF > Dockerfile
FROM redroid/redroid:11.0.0-latest
COPY system/ /system/
EOF
    docker build -t $IMAGE_NAME .
    cd ~ && rm -rf /root/redroid-build
    echo -e "${GREEN}>>> [OK] Perakitan Custom Image Selesai!${NC}"
else
    echo -e "\n${GREEN}>>> [SYSTEM] Custom Image ($IMAGE_NAME) sudah terdeteksi. Melewati proses perakitan.${NC}"
fi

# ==========================================================
# 2. GENERATE CHAOS IDENTITY
# ==========================================================
echo -e "\n${YELLOW}>>> [1/4] Menyiapkan Chaos Identity...${NC}"
NEW_HISTORY="/root/used_devices_setang.txt"
[ ! -f "$NEW_HISTORY" ] && touch "$NEW_HISTORY"

BRAND="realme"
MANUF="realme"
GT_PREFIX=("GT " "GT Neo " "GT Master " "GT Explorer ")
C_NUMS=(11 12 15 21 25 30 31 33 35 51 53 55 61 63 65 67 75 81 83 85)
EXTRA=(" Pro" " Pro+" " Ultra" " 5G" " Lite" " Turbo" " SE")
CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

while true; do
    RAND_CODE="${CHARS:RANDOM%26:1}${CHARS:RANDOM%26:1}${CHARS:RANDOM%26:1}$((RANDOM%900+100))"
    RAND_TYPE=$((RANDOM % 3))
    case $RAND_TYPE in
        0) MARKETING_NAME="Realme C${C_NUMS[$RANDOM % ${#C_NUMS[@]}]}${EXTRA[$RANDOM % ${#EXTRA[@]}]} ${RAND_CODE}" ;;
        1) MARKETING_NAME="Realme ${GT_PREFIX[$RANDOM % ${#GT_PREFIX[@]}]}$((RANDOM%8+2)) ${RAND_CODE}" ;;
        2) MARKETING_NAME="Narzo $((RANDOM%9+1))0${EXTRA[$RANDOM % ${#EXTRA[@]}]} ${RAND_CODE}" ;;
    esac
    REAL_MODEL="RMX$((RANDOM % 8000 + 1000))"
    GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
    GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    if ! grep -qE "$GEN_IMEI|$GEN_MAC|$GEN_SERIAL" "$NEW_HISTORY"; then break; fi
done

OS_VER=11
RAND_BUILD="${CHARS:RANDOM%26:1}${CHARS:RANDOM%26:1}$((RANDOM%9+1))A.$((RANDOM%899999+100000)).$((RANDOM%899+100))"
RAND_TS=$((RANDOM % 500000000 + 1600000000))
FINGERPRINT="${BRAND}/${REAL_MODEL}/${REAL_MODEL}:${OS_VER}/${RAND_BUILD}/${RAND_TS}:user/release-keys"

CHIPSETS=("mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900" "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1")
RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"

RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"

PORT=5555
CONTAINER_NAME="android_11_single"
DATA_DIR="$HOME/data_11_single"
WIDTH=720; HEIGHT=1600; DPI=320

echo "$CONTAINER_NAME | $MARKETING_NAME | $REAL_MODEL | $GEN_IMEI" >> "$NEW_HISTORY"

echo -e "${BLUE}>>> IDENTITY VIRTUAL (SINGLE):${NC}"
echo -e "Device Name   : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code    : ${BOLD}$REAL_MODEL${NC}"
echo -e "Fingerprint   : ${BOLD}$FINGERPRINT${NC}"
echo -e "Fake SOC      : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
echo -e "IMEI          : ${BOLD}$GEN_IMEI${NC}"
echo -e "MAC Address   : ${BOLD}$GEN_MAC${NC}"
echo -e "Serial Number : ${BOLD}$GEN_SERIAL${NC}"

# ==========================================================
# 3. START CONTAINER
# ==========================================================
echo -e "\n${YELLOW}>>> [2/4] Membersihkan Container Lama (Jika Ada)...${NC}"
docker rm -f $CONTAINER_NAME 2>/dev/null || true
rm -rf $DATA_DIR; mkdir -p $DATA_DIR

echo -e "${YELLOW}>>> [3/4] Menjalankan Android 11 + GApps di Port $PORT...${NC}"
docker run -itd --memory-swap="-1" --privileged --restart=always \
    --shm-size=2g -v $DATA_DIR:/data -p $PORT:5555 --name $CONTAINER_NAME \
    $IMAGE_NAME \
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
    ro.sys.fw.bg_apps_limit=128 >/dev/null

# ==========================================================
# 4. SMART WAIT & INJECT
# ==========================================================
echo -ne "${YELLOW}>>> [4/4] Booting OS (GApps butuh waktu sedikit lebih lama): ${NC}"
for (( c=1; c<=120; c++ )); do
    adb connect localhost:$PORT >/dev/null 2>&1
    [ "$(adb -s localhost:$PORT shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ] && break
    echo -ne "■"; sleep 1
done

# --- BYPASS BLACK SCREEN (SETUP WIZARD) ---
echo -e "\n${GREEN}>>> [INJECT] Mengeksekusi Bypass Google Setup Wizard (Anti Layar Hitam)...${NC}"
adb -s localhost:$PORT shell settings put secure user_setup_complete 1
adb -s localhost:$PORT shell settings put global device_provisioned 1
adb -s localhost:$PORT shell pm disable-user --user 0 com.google.android.setupwizard
# ------------------------------------------

adb -s localhost:$PORT shell "settings put global window_animation_scale 0; settings put global transition_animation_scale 0; settings put global animator_duration_scale 0"
adb -s localhost:$PORT shell "settings put global device_name \"$MARKETING_NAME\""
adb -s localhost:$PORT shell "setprop gsm.sim.state READY; setprop gsm.sim.operator.alpha Telkomsel"

DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.5.0/dukulive1775232812.apk"
DUKU_PATH="/root/duku.apk"
if [ ! -f "$DUKU_PATH" ]; then curl -L -o "$DUKU_PATH" "$DUKU_URL" >/dev/null 2>&1; fi
if [ -f "$DUKU_PATH" ]; then
    timeout 120 adb -s localhost:$PORT install -r "$DUKU_PATH" >/dev/null 2>&1
    adb -s localhost:$PORT shell am start -n "com.duku666.live/com.duku666.live.activity.SplashActivity" >/dev/null 2>&1
fi

echo -e "\n${CYAN}======================================================${NC}"
echo -e "${GREEN}${BOLD}✅ ANDROID 11 (GAPPS) BERHASIL DIBUAT!${NC}"
echo -e "${GREEN}   Akses melalui Port: $PORT${NC}"
echo -e "${CYAN}======================================================${NC}"
