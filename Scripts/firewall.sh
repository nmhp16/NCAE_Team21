#!/bin/bash

# Firewall Security Setup Script (Ubuntu Servers)
# For NCAE Cyber Games Competition
# Run this script on all servers in the infrastructure

echo "[START] Configuring UFW Firewall rules."

# Step 1: Update the package list and install UFW (if not installed)
echo "[INFO] Installing UFW firewall..."
sudo apt update
sudo apt install ufw -y

# Step 2: Set default firewall rules
echo "[INFO] Setting default firewall rules to deny all incoming and allow outgoing traffic..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Step 3: Allow essential services (SSH, HTTP, HTTPS)
echo "[INFO] Allowing SSH (port 22)..."
sudo ufw allow ssh

echo "[INFO] Allowing HTTP (port 80)..."
sudo ufw allow http

echo "[INFO] Allowing HTTPS (port 443)..."
sudo ufw allow https

# Step 4: Allow internal network access
echo "[INFO] Configuring internal network access..."
sudo ufw allow from 192.168.21.0/24 to any
sudo ufw allow from 172.18.0.0/16 to any

# Step 5: Allow specific service ports based on server role
# Web Server (192.168.21.5)
if [ "$(hostname -I | grep 192.168.21.5)" ]; then
    echo "[INFO] Configuring firewall for Web Server..."
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
fi

# Database Server (192.168.21.7)
if [ "$(hostname -I | grep 192.168.21.7)" ]; then
    echo "[INFO] Configuring firewall for Database Server..."
    sudo ufw allow from 192.168.21.5 to any port 3306
fi

# DNS Server (192.168.21.12)
if [ "$(hostname -I | grep 192.168.21.12)" ]; then
    echo "[INFO] Configuring firewall for DNS Server..."
    sudo ufw allow 53/tcp
    sudo ufw allow 53/udp
fi

# FTP Server (172.18.14.21)
if [ "$(hostname -I | grep 172.18.14.21)" ]; then
    echo "[INFO] Configuring firewall for FTP Server..."
    sudo ufw allow 21/tcp
    sudo ufw allow 40000:50000/tcp
fi

# Step 6: Enable the firewall (this will prompt confirmation)
echo "[INFO] Enabling firewall..."
sudo ufw --force enable

# Step 7: Check firewall status
echo "[INFO] Current firewall status:"
sudo ufw status verbose

echo "[COMPLETE] Firewall setup and rules applied successfully."

