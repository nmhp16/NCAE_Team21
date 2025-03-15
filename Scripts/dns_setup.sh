#!/bin/bash

# DNS Server Secure Setup Script
# Installs and configures BIND9 securely for NCAE Cyber Games
# Run ONLY on DNS Server (192.168.21.12)

echo "[START] DNS Server (BIND9) Installation and Security Setup."

# === Step 1: Update system and install BIND9 ===
echo "[INFO] Installing BIND9 DNS Server..."
sudo apt update && sudo apt install bind9 -y

# Enable BIND9 to start automatically
sudo systemctl enable bind9

# Step 2: Secure BIND9 Configuration (restrict queries and recursion)
echo "[INFO] Configuring secure DNS settings..."
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

# Overwrite named.conf.options with secure settings
sudo bash -c 'cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    allow-query { 
        localhost; 
        192.168.21.0/24;  # Internal LAN
        172.18.0.0/16;    # External LAN
    };
    recursion no;
    allow-transfer { none; };
    version "Not Available";
    listen-on { 192.168.21.12; 127.0.0.1; };
};
'

# Step 3: Configure firewall for DNS
echo "[INFO] Configuring firewall for DNS..."
sudo ufw allow 53/tcp
sudo ufw allow 53/udp

# Step 4: Restart BIND9 to apply changes
echo "[INFO] Restarting BIND9 service..."
sudo systemctl restart bind9

# Step 5: Check if DNS service is running
sudo systemctl status bind9 | grep Active

echo "[COMPLETE] DNS Server has been installed, secured, and started successfully."
echo "[INFO] DNS server is accessible at 192.168.21.12"

