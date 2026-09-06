#!/bin/bash

# Hentikan script jika ada error
set -e

echo "=========================================="
echo "  Setup Server MALAM TERAKHIR (Debian 12) "
echo "=========================================="

# 1. Update & Install Dependencies
echo "[1/6] Menginstall dependencies (wget, unzip, git)..."
sudo apt-get update -y
sudo apt-get install -y wget unzip git ufw

# 2. Install Godot Headless 4.3
echo "[2/6] Mengunduh dan memasang Godot 4.3 Headless..."
if [ ! -f "/usr/local/bin/godot" ]; then
    wget -q https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip -O /tmp/godot.zip
    unzip -q /tmp/godot.zip -d /tmp/
    sudo mv /tmp/Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot
    sudo chmod +x /usr/local/bin/godot
    rm /tmp/godot.zip
else
    echo "Godot sudah terpasang, melewati tahap ini."
fi

# 3. Clone Repository Game
echo "[3/6] Mengunduh source code game dari GitHub..."
REPO_DIR="/root/lele"
if [ -d "$REPO_DIR" ]; then
    echo "Folder lele sudah ada, melakukan git pull untuk update..."
    cd "$REPO_DIR"
    git reset --hard HEAD
    git pull origin main
else
    cd /root
    git clone https://github.com/lmob3381-tech/lele.git "$REPO_DIR"
fi

# 4. Membuat Systemd Service
echo "[4/6] Mengonfigurasi Systemd Service di background..."
cat <<EOF | sudo tee /etc/systemd/system/malam-terakhir.service > /dev/null
[Unit]
Description=Malam Terakhir Game Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REPO_DIR
ExecStart=/usr/local/bin/godot --headless --server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. Konfigurasi Firewall
echo "[5/6] Membuka port 10403 (TCP/UDP) di firewall..."
sudo ufw allow 10403/tcp > /dev/null
sudo ufw allow 10403/udp > /dev/null

# 6. Start Service
echo "[6/6] Menyalakan game server..."
sudo systemctl daemon-reload
sudo systemctl enable malam-terakhir
sudo systemctl restart malam-terakhir

echo "=========================================="
echo "  SETUP SELESAI! Server sudah berjalan.   "
echo "                                          "
echo "  Cek status: systemctl status malam-terakhir"
echo "  Lihat log:  journalctl -u malam-terakhir -f"
echo "=========================================="
