#!/bin/bash

# Cowrie Honeypot Setup Script (Ubuntu)
# Use ONLY on Dedicated Honeypot Server (Isolated VM)
# Run on External Kali VM (172.18.15.211-172.18.15.216)

echo "[START] Setting up Cowrie SSH Honeypot."

# Step 1: Update system packages
echo "[INFO] Updating system packages..."
sudo apt update -y

# Step 2: Install dependencies (Python, git, pip)
echo "[INFO] Installing dependencies (Python, pip, git)..."
sudo apt install python3 python3-pip python3-venv git -y

# Step 3: Configure firewall for honeypot
echo "[INFO] Configuring firewall for honeypot..."
sudo ufw allow 22/tcp
sudo ufw allow 2222/tcp  # Cowrie's default port
sudo ufw allow from 172.18.0.0/16 to any  # Allow internal network access

# Step 4: Clone Cowrie Honeypot Repository
echo "[INFO] Cloning Cowrie..."
cd ~
git clone https://github.com/cowrie/cowrie.git
cd cowrie

# Step 5: Install Python requirements for Cowrie
echo "[INFO] Installing Cowrie requirements..."
python3 -m venv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Step 6: Configure Cowrie
echo "[INFO] Configuring Cowrie..."
cp etc/cowrie.cfg.dist etc/cowrie.cfg
sed -i 's/^listen_port = 2222/listen_port = 22/' etc/cowrie.cfg
sed -i 's/^listen_endpoints = tcp:2222/listen_endpoints = tcp:22/' etc/cowrie.cfg
sed -i 's/^hostname = svr04/hostname = team21-honeypot/' etc/cowrie.cfg

# Step 7: Start Cowrie SSH Honeypot
echo "[INFO] Starting Cowrie SSH honeypot..."
bin/cowrie start

# Verify that Cowrie is running
echo "[INFO] Checking if Cowrie is running..."
sleep 3
if pgrep -f "twistd -n cowrie" >/dev/null; then
    echo "[SUCCESS] Cowrie honeypot is running!"
    echo "[INFO] Honeypot is accessible on port 22"
    echo "[INFO] Logs are available at ~/cowrie/var/log/cowrie/cowrie.log"
else
    echo "[ERROR] Cowrie failed to start. Check logs at ~/cowrie/var/log/cowrie/cowrie.log"
fi

