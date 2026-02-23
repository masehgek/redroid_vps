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
echo -e "${CYAN}${BOLD}  SETANG TUYUL TOOLS - V14.14 (STRICT IP BLOCK)    ${NC}"
echo -e "${CYAN}${BOLD}     ZERO TOLERANCE IP | INFINITE DEVICE | 24GB    ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit; fi

# Variable Init
MAX_RETRIES=5
RETRY_COUNT=0

# ==========================================================
#   1. SETUP LOGGING
# ==========================================================
OLD_HISTORY="/root/.used_devices"
NEW_HISTORY="/root/used_devices_setang.txt"
IP_HISTORY="/root/used_ips_setang.txt"

if [ -f "$OLD_HISTORY" ]; then mv "$OLD_HISTORY" "$NEW_HISTORY"; fi
if [ ! -f "$NEW_HISTORY" ]; then touch "$NEW_HISTORY"; fi
if [ ! -f "$IP_HISTORY" ]; then touch "$IP_HISTORY"; fi

HISTORY_FILE="$NEW_HISTORY"

echo -e "${GREEN}>>> Device Log : $HISTORY_FILE${NC}"
echo -e "${GREEN}>>> IP Log     : $IP_HISTORY${NC}"

# ==========================================================
#   2. SWAP SAFETY (4GB)
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
#   3. SMART DRIVER CHECK
# ==========================================================
if ! lsmod | grep -q binder_linux; then
    modprobe binder_linux devices="binder,hwbinder,vndbinder" >/dev/null 2>&1
    modprobe ashmem_linux >/dev/null 2>&1
    
    if ! lsmod | grep -q binder_linux; then
        echo -e "${YELLOW}>>> [SYSTEM] Auto-Repair Driver (Fresh Install)...${NC}"
        apt-get update -y >/dev/null 2>&1
        apt-get install -y linux-modules-extra-$(uname -r) linux-tools-common linux-tools-generic linux-tools-$(uname -r) >/dev/null 2>&1
        modprobe binder_linux devices="binder,hwbinder,vndbinder"
        modprobe ashmem_linux
    else
        echo -e "${GREEN}>>> [SYSTEM] Driver Recovered.${NC}"
    fi
else
    echo -e "${GREEN}>>> [SYSTEM] Driver Ready.${NC}"
fi

if ! command -v docker &> /dev/null || ! command -v adb &> /dev/null; then
    echo -e "${YELLOW}>>> [INSTALL] Docker & ADB...${NC}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y docker.io android-tools-adb curl unzip dos2unix coreutils >/dev/null 2>&1
    systemctl start docker; systemctl enable docker
fi

# ==========================================================
#   4. CLEAN UP (HARD KILL)
# ==========================================================
echo -e "${YELLOW}>>> [CLEAN] Memastikan Container Mati...${NC}"
docker rm -f android_11 >/dev/null 2>&1
rm -rf ~/data_11; mkdir -p ~/data_11

# ==========================================================
#   5. DATABASE (100 REALME)
# ==========================================================
DEVICES=(
    "realme|realme|Realme 1|realme/CPH1859/CPH1861:8.1.0/O11019/1566897325:user/release-keys"
    "realme|realme|Realme 2|realme/RMX1805/RMX1805:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme 2 Pro|realme/RMX1801/RMX1801:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme U1|realme/RMX1831/RMX1831:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme C1|realme/RMX1811/RMX1811:8.1.0/O11019/1566897325:user/release-keys"
    "realme|realme|Realme C2|realme/RMX1941/RMX1941:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme 3|realme/RMX1821/RMX1821:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 3 Pro|realme/RMX1851/RMX1851:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 3i|realme/RMX1827/RMX1827:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme 5|realme/RMX1911/RMX1911:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 5 Pro|realme/RMX1971/RMX1971:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 5i|realme/RMX2030/RMX2030:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme 5s|realme/RMX1925/RMX1925:9/PKQ1.190616.001/1574067325:user/release-keys"
    "realme|realme|Realme XT|realme/RMX1921/RMX1921:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme X|realme/RMX1901/RMX1901:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme X2|realme/RMX1992/RMX1992:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme X2 Pro|realme/RMX1931/RMX1931:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme X50 Pro|realme/RMX2076/RMX2076:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme 6|realme/RMX2001/RMX2001:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 6 Pro|realme/RMX2061/RMX2061:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 6i|realme/RMX2040/RMX2040:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 6s|realme/RMX2002/RMX2002:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 7|realme/RMX2151/RMX2151:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme 7 Pro|realme/RMX2170/RMX2170:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme 7i|realme/RMX2103/RMX2103:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 7 5G|realme/RMX2111/RMX2111:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme 8|realme/RMX3085/RMX3085:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme 8 Pro|realme/RMX3081/RMX3081:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme 8i|realme/RMX3151/RMX3151:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme 8 5G|realme/RMX3241/RMX3241:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme 8s 5G|realme/RMX3381/RMX3381:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Realme 9|realme/RMX3521/RMX3521:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Realme 9 Pro|realme/RMX3471/RMX3471:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Realme 9 Pro+|realme/RMX3392/RMX3392:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Realme 9i|realme/RMX3491/RMX3491:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme 9i 5G|realme/RMX3612/RMX3612:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme 9 SE|realme/RMX3461/RMX3461:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme 10|realme/RMX3630/RMX3630:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Realme 10 Pro|realme/RMX3660/RMX3660:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Realme 10 Pro+|realme/RMX3686/RMX3686:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Realme 10 5G|realme/RMX3663/RMX3663:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme 11|realme/RMX3751/RMX3751:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme 11 Pro|realme/RMX3771/RMX3771:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme 11 Pro+|realme/RMX3741/RMX3741:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme 11x 5G|realme/RMX3785/RMX3785:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme 12 Pro+|realme/RMX3840/RMX3840:14/UP1A.231005.007/1706882294:user/release-keys"
    "realme|realme|Realme 12 Pro|realme/RMX3842/RMX3842:14/UP1A.231005.007/1706882294:user/release-keys"
    "realme|realme|Realme 12+|realme/RMX3867/RMX3867:14/UP1A.231005.007/1706882294:user/release-keys"
    "realme|realme|Realme C3|realme/RMX2020/RMX2020:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C3i|realme/RMX2021/RMX2021:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C11|realme/RMX2185/RMX2185:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C11 2021|realme/RMX3231/RMX3231:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme C12|realme/RMX2189/RMX2189:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C15|realme/RMX2180/RMX2180:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C17|realme/RMX2101/RMX2101:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C20|realme/RMX3061/RMX3061:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C21|realme/RMX3201/RMX3201:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme C21Y|realme/RMX3261/RMX3261:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme C25|realme/RMX3191/RMX3191:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme C25s|realme/RMX3195/RMX3195:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme C25Y|realme/RMX3265/RMX3265:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme C30|realme/RMX3581/RMX3581:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Realme C30s|realme/RMX3690/RMX3690:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme C31|realme/RMX3501/RMX3501:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Realme C33|realme/RMX3624/RMX3624:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme C35|realme/RMX3511/RMX3511:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Realme C51|realme/RMX3830/RMX3830:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme C53|realme/RMX3760/RMX3760:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Realme C55|realme/RMX3710/RMX3710:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Realme C67|realme/RMX3890/RMX3890:14/UP1A.231005.007/1706882294:user/release-keys"
    "realme|realme|Narzo 10|realme/RMX2040/RMX2040:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Narzo 10A|realme/RMX2020/RMX2020:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Narzo 20|realme/RMX2191/RMX2191:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Narzo 20 Pro|realme/RMX2161/RMX2161:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Narzo 20A|realme/RMX2050/RMX2050:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Narzo 30|realme/RMX2156/RMX2156:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Narzo 30 Pro|realme/RMX2117/RMX2117:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Narzo 30 5G|realme/RMX3242/RMX3242:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Narzo 50|realme/RMX3286/RMX3286:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Narzo 50 Pro 5G|realme/RMX3395/RMX3395:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Narzo 50 5G|realme/RMX3571/RMX3571:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Narzo 50A|realme/RMX3430/RMX3430:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Narzo 50i|realme/RMX3231/RMX3231:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Narzo 60|realme/RMX3750/RMX3750:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Narzo 60 Pro|realme/RMX3740/RMX3740:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Narzo N55|realme/RMX3710/RMX3710:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Narzo N53|realme/RMX3761/RMX3761:13/TP1A.220905.001/1683882294:user/release-keys"
    "realme|realme|Realme GT|realme/RMX2202/RMX2202:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme GT Neo|realme/RMX3031/RMX3031:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme GT Neo Flash|realme/RMX3350/RMX3350:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme GT Master|realme/RMX3363/RMX3363:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|Realme GT Master Explorer|realme/RMX3366/RMX3366:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|Realme GT Neo 2|realme/RMX3370/RMX3370:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme GT 2|realme/RMX3312/RMX3312:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme GT 2 Pro|realme/RMX3301/RMX3301:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|Realme GT Neo 3|realme/RMX3561/RMX3561:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|Realme GT Neo 3T|realme/RMX3371/RMX3371:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|Realme GT 3|realme/RMX3709/RMX3709:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|Realme GT 5|realme/RMX3820/RMX3820:13/TP1A.220905.001/1692882294:user/release-keys"
    "realme|realme|Realme GT 5 Pro|realme/RMX3888/RMX3888:14/UP1A.231005.007/1701382294:user/release-keys"
    "realme|realme|Realme Q2|realme/RMX2117/RMX2117:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme Q2 Pro|realme/RMX2173/RMX2173:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme Q3|realme/RMX3161/RMX3161:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme Q3 Pro|realme/RMX2205/RMX2205:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme Q3s|realme/RMX3461/RMX3461:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme Q5|realme/RMX3478/RMX3478:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme Q5 Pro|realme/RMX3372/RMX3372:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme V3|realme/RMX2200/RMX2200:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme V5|realme/RMX2111/RMX2111:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme V11|realme/RMX3121/RMX3121:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme V13|realme/RMX3041/RMX3041:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|Realme V15|realme/RMX3092/RMX3092:10/QKQ1.191222.002/1598426543:user/release-keys"
    "realme|realme|Realme V23|realme/RMX3571/RMX3571:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|Realme V25|realme/RMX3475/RMX3475:12/SP1A.210812.016/1660230230:user/release-keys"
)

CHIPSETS=(
    "mt6765|MediaTek|Helio P35" "mt6762|MediaTek|Helio P22" "mt6771|MediaTek|Helio P60" "mt6769|MediaTek|Helio G85"
    "bengal|Qualcomm|Snapdragon 665" "atoll|Qualcomm|Snapdragon 720G" "lito|Qualcomm|Snapdragon 765G" "kona|Qualcomm|Snapdragon 865"
    "lahaina|Qualcomm|Snapdragon 888" "taro|Qualcomm|Snapdragon 8 Gen 1" "mt6893|MediaTek|Dimensity 1200" "mt6877|MediaTek|Dimensity 900"
)
RAND_DATA=${CHIPSETS[$RANDOM % ${#CHIPSETS[@]}]}
IFS='|' read -r CHIP_BOARD CHIP_MANUF CHIP_MODEL <<< "$RAND_DATA"

# ==========================================================
#   6. PICK DEVICE (LOGIC STRICT: NO REPEAT)
# ==========================================================
TOTAL_DEVICES=${#DEVICES[@]}
[ ! -f "$HISTORY_FILE" ] && touch "$HISTORY_FILE"
USED_COUNT=$(wc -l < "$HISTORY_FILE")
REMAINING=$((TOTAL_DEVICES - USED_COUNT))

echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}>>> SETANG TUYUL-TOOLS (V14.13 - STRICT LOGGING)${NC}"
echo -e "${CYAN}>>> Total: $TOTAL_DEVICES | Sisa: $REMAINING${NC}"
echo -e "${CYAN}==============================================${NC}"

if [ "$REMAINING" -le 0 ]; then echo -e "${RED}[STOP] DB HABIS. Reset: rm $HISTORY_FILE${NC}"; exit 1; fi

while true; do
    RANDOM_INDEX=$((RANDOM % TOTAL_DEVICES))
    IFS='|' read -r TMP_BRAND TMP_MANUF TMP_MODEL TMP_FINGER <<< "${DEVICES[$RANDOM_INDEX]}"
    if ! grep -Fxq "$TMP_MODEL" "$HISTORY_FILE"; then
        BRAND=$TMP_BRAND; MANUF=$TMP_MANUF; MARKETING_NAME=$TMP_MODEL; FINGERPRINT=$TMP_FINGER
        REAL_MODEL=$(echo "$FINGERPRINT" | cut -d'/' -f2)
        break
    fi
done

# ==========================================================
#   7. DATA SIM & IP CHECK (ZERO TOLERANCE)
# ==========================================================
GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"
GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MY_IP=$(curl -s ifconfig.me || echo "Offline")

# --- ZERO TOLERANCE IP GUARD ---
if grep -Fxq "$MY_IP" "$IP_HISTORY"; then
    echo -e "${RED}${BOLD}==============================================${NC}"
    echo -e "${RED}${BOLD}[BAHAYA] IP INI ($MY_IP) SUDAH TERPAKAI!${NC}"
    echo -e "${RED}System mendeteksi IP ini ada di history.${NC}"
    echo -e "${YELLOW}Wajib GANTI IP untuk melanjutkan!${NC}"
    echo -e "${RED}${BOLD}==============================================${NC}"
    exit 1
else
    echo "$MY_IP" >> "$IP_HISTORY"
    echo -e "${GREEN}[OK] IP Aman (New).${NC}"
fi

echo -e "${BLUE}>>> NEW IDENTITY:${NC}"
echo -e "Brand        : ${BOLD}$BRAND${NC}"
echo -e "Device Name  : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code   : ${BOLD}$REAL_MODEL${NC}"
echo -e "Fake SOC     : ${BOLD}$CHIP_MODEL ($CHIP_BOARD)${NC}"
echo -e "IP           : ${BOLD}$MY_IP${NC}"

# ==========================================================
#   8. START CONTAINER (WITH AUTO-RETRY LOOP & HARD KILL)
# ==========================================================
echo -e "${YELLOW}>>> [STARTING] Android 11 (16GB Physical RAM - 4 CPU)...${NC}"

# HARD KILL SEBELUM MULAI (Agar tidak Conflict)
docker rm -f android_11 >/dev/null 2>&1

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    
    # 1. Start Docker
    sudo docker run -itd --memory="16g" --memory-swap="-1" --cpus="4" --privileged --restart=always \
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

    # 2. Hapus keys
    sleep 2; sudo docker exec android_11 rm -f /data/misc/adb/adb_keys; sudo docker exec android_11 killall adbd

    # 3. FAST CHECK BOOT (WATCHDOG)
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

# SAVE HISTORY DEVICE (WAJIB ADA)
echo "$MARKETING_NAME" >> "$HISTORY_FILE"

# ==========================================================
#   9. INJECT SIM & NO ANIMATION
# ==========================================================
echo -e "${GREEN}>>> [INJECT] SIM & Disable Animations...${NC}"
adb -s localhost:5555 wait-for-device

# MATIKAN ANIMASI
adb -s localhost:5555 shell settings put global window_animation_scale 0
adb -s localhost:5555 shell settings put global transition_animation_scale 0
adb -s localhost:5555 shell settings put global animator_duration_scale 0

# SETTINGS
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
#   10. INSTALL APK & AUTO-OPTIMIZE
# ==========================================================
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.2/dukulive1770365885.apk"
DUKU_PATH="/root/duku.apk"

if [ ! -f "$DUKU_PATH" ]; then echo -e "${YELLOW}>>> [DOWNLOAD] Duku APK...${NC}"; curl -L -o "$DUKU_PATH" "$DUKU_URL"; fi
if [ -f "$DUKU_PATH" ]; then
    echo -e "${GREEN}>>> [INSTALL] Duku Live...${NC}"
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH"
    
    # --- AUTO DETECT & OPTIMIZE ---
    echo -e "${BLUE}>>> [OPTIMIZE] Mencegah Force Close...${NC}"
    PKG_NAME=$(adb -s localhost:5555 shell pm list packages -3 | awk -F: '{print $2}' | head -n 1)
    
    if [ ! -z "$PKG_NAME" ]; then
        echo -e "${CYAN}>>> Target: $PKG_NAME${NC}"
        adb -s localhost:5555 shell dumpsys deviceidle disable $PKG_NAME >/dev/null 2>&1
        adb -s localhost:5555 shell cmd appops set $PKG_NAME RUN_IN_BACKGROUND allow >/dev/null 2>&1
        echo -e "${GREEN}${BOLD}>>> [SUKSES] Terpasang & Optimized!${NC}"
    else
        echo -e "${RED}>>> [WARN] Nama paket tidak ditemukan.${NC}"
    fi
fi
echo -e "${CYAN}==============================================${NC}"
