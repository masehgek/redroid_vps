#!/bin/bash

# Warna
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "======================================================"
echo "      SETANG TUYUL TOOLS - LITE VERSION (A12)       "
echo "======================================================"

# 0. Cek ADB & Curl (Pastikan terinstall)
if ! command -v adb &> /dev/null || ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}>>> [INSTALL] Menginstal ADB & Curl...${NC}"
    apt-get update -y && apt-get install -y android-tools-adb curl >/dev/null 2>&1
fi

# 1. Bersihkan port, container lama, dan data lama
echo -e "${YELLOW}>>> [CLEAN] Membersihkan semua container dan port lama...${NC}"
docker rm -f android_11 android_8 redroid ws-scrcpy >/dev/null 2>&1
adb kill-server >/dev/null 2>&1
rm -rf ~/data ~/data_11 ~/data_8
mkdir -p ~/data

# 2. Jalankan Android 12 (Standar - 32 & 64 bit)
echo -e "${YELLOW}>>> [STARTING] Menjalankan Android 12...${NC}"
docker run -itd --privileged --restart always \
    --name redroid \
    --pull always \
    -v ~/data:/data \
    -p 5555:5555 \
    redroid/redroid:12.0.0-latest \
    androidboot.redroid_gpu_mode=guest \
    debug.sf.disable_hwc=1 \
    debug.sf.nobootanimation=1 \
    androidboot.redroid_width=720 \
    androidboot.redroid_height=1280 \
    androidboot.redroid_dpi=320

# 3. Tunggu Booting agar ADB bisa konek
echo -e "${YELLOW}>>> [WAIT] Menunggu Android Booting (Maks 15 detik)...${NC}"
for (( c=1; c<=15; c++ )); do
    adb connect localhost:5555 >/dev/null 2>&1
    STATUS=$(adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$STATUS" == "1" ]; then
        break
    fi
    sleep 1
done

# 4. Instal APK Duku
echo -e "${YELLOW}>>> [INSTALL] Menyiapkan Duku Live...${NC}"
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.2/dukulive1770365885.apk"
DUKU_PATH="/root/duku.apk"

if [ ! -f "$DUKU_PATH" ]; then 
    echo -e "${YELLOW}>>> Mengunduh Duku APK...${NC}"
    curl -L -o "$DUKU_PATH" "$DUKU_URL"
fi

if [ -f "$DUKU_PATH" ]; then
    adb -s localhost:5555 wait-for-device
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH"
    echo -e "${GREEN}>>> [SUKSES] APK Duku Terpasang!${NC}"
fi

# 5. Jalankan Web Control
echo -e "${YELLOW}>>> [STARTING] Menjalankan Web Control...${NC}"
docker run -d \
    --name ws-scrcpy \
    --network host \
    --restart always \
    scavin/ws-scrcpy:latest >/dev/null 2>&1

# 6. Info Akses
MY_IP=$(curl -s ifconfig.me)
echo "======================================================"
echo -e "${GREEN}>>> [SELESAI] Android 12 & Web Control Berjalan!${NC}"
echo ">>> Akses Web Control di: http://$MY_IP:8000"
echo "======================================================"
