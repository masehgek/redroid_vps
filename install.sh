#!/bin/bash

# ==========================================================
#  REDROID AUTO INSTALLER (HOST MODE / DIRECT NETWORK)
#  Device: Realme RMX3241 | Res: 720x1600 | DPI: 320
#  Fix: Client Disconnected / Keep Alive Error on Mobile
# ==========================================================

echo "========================================="
echo "   STARTING REDROID INSTALLATION         "
echo "   Mode: HOST NETWORK (Bypass Bridge)    "
echo "========================================="

# 1. SETUP DOCKER & KERNEL DRIVERS
# Wajib untuk VPS Fresh/Kosong
echo "[+] Installing Docker & Kernel Modules..."
sudo apt-get update -y
sudo apt-get install -y docker.io linux-modules-extra-$(uname -r)

# 2. AKTIFKAN DRIVER BINDER & ASHMEM
echo "[+] Enabling Binder & Ashmem Drivers..."
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder"
sudo modprobe ashmem_linux
# Simpan config agar permanen
echo "binder_linux" | sudo tee /etc/modules-load.d/redroid.conf
echo "ashmem_linux" | sudo tee -a /etc/modules-load.d/redroid.conf

# 3. ENABLE DOCKER SERVICE
sudo systemctl enable --now docker

# 4. CLEANUP OLD CONTAINER
echo "[+] Removing old containers..."
sudo docker rm -f android_8 >/dev/null 2>&1

# 5. GENERATE RANDOM IDENTITY
RANDOM_IMEI=$(shuf -i 350000000000000-359999999999999 -n 1)
RANDOM_SERIAL="RMX$(shuf -i 1000000-9999999 -n 1)"

echo "[+] Generated ID: $RANDOM_SERIAL"

# 6. RUN REDROID CONTAINER
# Menggunakan --net=host untuk mengatasi masalah timeout di HP
echo "[+] Starting Android..."
sudo docker run -itd \
    --privileged --pull always \
    --restart=always \
    --net=host \
    --cpus="4" \
    --memory-swappiness=0 \
    -v ~/data:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ="Asia/Jakarta" \
    --name android_8 \
    redroid/redroid:8.1.0-latest \
    androidboot.redroid_width=720 \
    androidboot.redroid_height=1600 \
    androidboot.redroid_dpi=320 \
    androidboot.redroid_gpu_mode=guest \
    androidboot.serialno=$RANDOM_SERIAL \
    ro.serialno=$RANDOM_SERIAL \
    ro.product.model=RMX3241 \
    ro.product.brand=realme \
    ro.product.manufacturer=realme \
    ro.build.fingerprint="realme/RMX3241/RMX3241:11/RP1A.200720.011/1626337852:user/release-keys" \
    ro.ril.oem.imei=$RANDOM_IMEI \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    persist.sys.timezone=Asia/Jakarta \
    persist.sys.language=id \
    persist.sys.country=ID

echo "========================================="
echo "   INSTALLATION SUCCESS!"
echo "   Connect via ADB: <IP_VPS>:5555"
echo "========================================="
