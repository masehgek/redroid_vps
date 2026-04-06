#!/bin/bash
# ==========================================================
# SETANG TUYUL TOOLS - V14.22 (ALL-IN-ONE SAPU JAGAT)
# Auto Firewall + Dynamic Input + Ultra Chaos Identity
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
echo -e "${CYAN}${BOLD}  SETANG TUYUL TOOLS - V14.22 (ALL-IN-ONE FINAL)      ${NC}"
echo -e "${CYAN}${BOLD}  Oracle ARM | Auto Firewall | Chaos Random Identity  ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit 1;
fi

# ==========================================================
# 1. AUTO-UPDATE FIREWALL (Buka Port 5554-5599)
# ==========================================================
echo -e "${YELLOW}>>> [SYSTEM] Mengecek dan Membuka Jalur Port VPS...${NC}"
apt-get update -y >/dev/null 2>&1
apt-get install -y iptables-persistent netfilter-persistent adb curl unzip >/dev/null 2>&1
iptables -I INPUT -p tcp -m tcp --dport 5554:5599 -j ACCEPT
netfilter-persistent save >/dev/null 2>&1
netfilter-persistent reload >/dev/null 2>&1
echo -e "${GREEN}>>> [OK] Firewall OS Terbuka (Port 5554 - 5599 siap pakai).${NC}"

# ==========================================================
# 2. INPUT USER
# ==========================================================
echo -ne "\n${YELLOW}${BOLD}>>> Masukkan jumlah virtual device yang ingin dibuat: ${NC}"
read TOTAL_INSTANCES

if ! [[ "$TOTAL_INSTANCES" =~ ^[0-9]+$ ]] || [ "$TOTAL_INSTANCES" -le 0 ]; then
   echo -e "${RED}ERROR: Harap masukkan angka yang valid!${NC}"; exit 1
fi

# ==========================================================
# 3. CONFIGURATION & IP CHECK
# ==========================================================
IP_HISTORY="/root/used_ips_setang.txt"
NEW_HISTORY="/root/used_devices_setang.txt"
[ ! -f "$IP_HISTORY" ] && touch "$IP_HISTORY"
[ ! -f "$NEW_HISTORY" ] && touch "$NEW_HISTORY"

MY_IP=$(curl -s ifconfig.me || echo "Offline")
if grep -Fxq "$MY_IP" "$IP_HISTORY"; then
    echo -e "${RED}${BOLD}[BAHAYA] IP INI ($MY_IP) SUDAH TERPAKAI!${NC}"
    echo -ne "${YELLOW}Tetap paksa lanjut? (y/n): ${NC}"
    read CONFIRM
    [[ "$CONFIRM" != "y" ]] && exit 1
else
    echo "$MY_IP" >> "$IP_HISTORY"
fi

WIDTH=720; HEIGHT=1600; DPI=320

# Swap Check
SWAP_FILE="/swapfile"
if [ ! -f "$SWAP_FILE" ]; then
    echo -e "${YELLOW}>>> [SYSTEM] Membuat Safety Swap 4GB...${NC}"
    fallocate -l 4G $SWAP_FILE; chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE >/dev/null 2>&1; swapon $SWAP_FILE
    if ! grep -q "$SWAP_FILE" /etc/fstab; then echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab; fi
fi
sysctl vm.swappiness=10 >/dev/null

if ! lsmod | grep -q binder_linux; then
    modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null || true
fi
systemctl start docker 2>/dev/null || true

# ==========================================================
# 4. MULAI LOOPING PEMBUATAN VIRTUAL
# ==========================================================
for i in $(seq 1 $TOTAL_INSTANCES); do
    PORT=$((5554 + i))
    CONTAINER_NAME="android_11_$i"
    DATA_DIR="$HOME/data_11_$i"
    
    echo -e "\n${CYAN}${BOLD}>>> MEMPROSES VIRTUAL KE-$i (Port: $PORT) <<<${NC}"

    # Chaos Identity Generator
    BRAND="realme"
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

    OS_VER=$((RANDOM % 4 + 12))
    RAND_BUILD="${CHARS:RANDOM%26:1}${CHARS:RANDOM%26:1}$((RANDOM%9+1))A.$((RANDOM%899999+100000)).$((RANDOM%899+100))"
    RAND_TS=$((RANDOM % 500000000 + 1600000000))
    FINGERPRINT="${BRAND}/${REAL_MODEL}/${REAL_MODEL}:${OS_VER}/${RAND_BUILD}/${RAND_TS}:user/release-keys"

    CHIPSETS=("mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900" "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1")
    RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
    IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"

    RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
    GEN_PHONE="+628${RAND_SUFFIX}"

    echo "BRAND=$BRAND | NAME=$MARKETING_NAME | MODEL=$REAL_MODEL | FINGERPRINT=$FINGERPRINT | IMEI=$GEN_IMEI | MAC=$GEN_MAC | SERIAL=$GEN_SERIAL | SOC=$CHIP_MODEL" >> "$NEW_HISTORY"

    echo -e "${BLUE}>>> IDENTITY VIRTUAL $i:${NC}"
    echo -e "Device Name   : ${BOLD}$MARKETING_NAME${NC}"
    echo -e "Model Code    : ${BOLD}$REAL_MODEL${NC}"
    echo -e "Fingerprint   : ${BOLD}$FINGERPRINT${NC}"
    echo -e "Fake SOC      : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
    echo -e "IMEI          : ${BOLD}$GEN_IMEI${NC}"
    echo -e "MAC Address   : ${BOLD}$GEN_MAC${NC}"

    # Container Execution
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    rm -rf $DATA_DIR; mkdir -p $DATA_DIR

    docker run -itd --memory-swap="-1" --privileged --restart=always \
        --shm-size=2g -v $DATA_DIR:/data -p $PORT:5555 --name $CONTAINER_NAME \
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
        ro.sys.fw.bg_apps_limit=128 >/dev/null

    # Smart Wait
    echo -ne "${YELLOW}>>> Booting V$i: ${NC}"
    for (( c=1; c<=60; c++ )); do
        adb connect localhost:$PORT >/dev/null 2>&1
        [ "$(adb -s localhost:$PORT shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ] && break
        echo -ne "■"; sleep 1
    done

    # Final Inject
    adb -s localhost:$PORT shell "settings put global window_animation_scale 0; settings put global transition_animation_scale 0; settings put global animator_duration_scale 0"
    adb -s localhost:$PORT shell "settings put global device_name \"$MARKETING_NAME\""
    adb -s localhost:$PORT shell "setprop gsm.sim.state READY; setprop gsm.sim.operator.alpha Telkomsel"
    
    # Install Duku
    DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.5.0/dukulive1775232812.apk"
    DUKU_PATH="/root/duku.apk"
    if [ ! -f "$DUKU_PATH" ]; then
        curl -L -o "$DUKU_PATH" "$DUKU_URL" >/dev/null 2>&1
    fi
    if [ -f "$DUKU_PATH" ]; then
        timeout 120 adb -s localhost:$PORT install -r "$DUKU_PATH" >/dev/null 2>&1
        adb -s localhost:$PORT shell am start -n "com.duku666.live/com.duku666.live.activity.SplashActivity" >/dev/null 2>&1
    fi
    
    echo -e "\n${GREEN}>>> VIRTUAL $i READY (Port: $PORT)${NC}"
done

echo -e "\n${CYAN}==============================================${NC}"
echo -e "${GREEN}${BOLD}✅ BERHASIL MEMBUAT $TOTAL_INSTANCES VIRTUAL DEVICES!${NC}"
echo -e "${CYAN}==============================================${NC}"
