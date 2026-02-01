# Redroid Host-Mode Installer (Anti-Disconnect) 🚀

Script instalasi otomatis untuk **Redroid (Android in Docker)** yang dioptimalkan khusus untuk koneksi dari HP Android. Menggunakan metode `--net=host` untuk mengatasi masalah *Client Disconnected* atau *Keep Alive Error*.

### 📱 Spesifikasi Device
* **Model:** Realme RMX3241 (Spoofed)
* **Resolution:** 720x1600 (HD+)
* **DPI:** 320
* **Android Version:** 8.1 (Oreo)
* **Network:** Host Mode (Direct Connection)
* **Security:** ADB Secure Disabled (No Auth Popup)

### 🛠️ Fitur Utama
1.  **Auto Driver Install:** Otomatis memasang `binder_linux` dan `ashmem_linux`.
2.  **Fix Timeout:** Menggunakan *Host Networking* untuk bypass NAT Docker yang sering bikin putus di jaringan seluler.
3.  **No Limit:** PID Limit & Ulimit dilepas untuk performa maksimal.
4.  **Auto Wake:** Layar dikonfigurasi agar mudah diremote.

### 📥 Cara Install (Di VPS Ubuntu/Debian)

Cukup jalankan perintah ini di terminal VPS (sebagai root):

Versi TUYUL:
```bash
https://raw.githubusercontent.com/masehgek/redroid_vps/main/tuyul.sh && chmod +x tuyul.sh && mv tuyul.sh generate.sh && ./generate.sh

```
Versi gen :
```bash
wget https://raw.githubusercontent.com/masehgek/redroid_vps/main/gen.sh && chmod +x gen.sh && ./gen.sh

```
Versi Host :
```bash
# 1. Download Script
wget https://raw.githubusercontent.com/masehgek/redroid_vps/main/install.sh

# 2. Beri Izin Eksekusi
chmod +x install.sh

# 3. Jalankan
./install.sh
