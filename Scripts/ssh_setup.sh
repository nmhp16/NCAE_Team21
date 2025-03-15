#!/bin/bash

# SSH Security and User Account Setup Script
# For NCAE Cyber Games Competition
# Run this script on all servers in the infrastructure

echo "[START] SSH setup and user creation script."

# === Step 1: Create user accounts ===
# Replace usernames and passwords as needed below:
declare -A users=(
  ["admin"]="CHANGE_THIS_PASSWORD"
  ["webadmin"]="CHANGE_THIS_PASSWORD"
  ["dbadmin"]="CHANGE_THIS_PASSWORD"
  ["dnsadmin"]="CHANGE_THIS_PASSWORD"
  ["ftpadmin"]="CHANGE_THIS_PASSWORD"
  ["monitor"]="CHANGE_THIS_PASSWORD"
  ["backup"]="CHANGE_THIS_PASSWORD"
)

for username in "${!users[@]}"; do
    password=${users[$username]}
    echo "[INFO] Creating user: $username"
    
    # Add user and include in sudo group
    sudo useradd -m -s /bin/bash -G sudo "$username"
    
    # Set user password
    echo "$username:$password" | sudo chpasswd

    # Force password change on first login
    sudo chage -d 0 "$username"

    echo "[SUCCESS] User $username created and password set."
done

echo "[COMPLETE] All users created."

# === Step 2: Secure SSH Configuration ===
echo "[INFO] Securing SSH configuration."

# Backup original SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configure SSH security settings
sudo bash -c 'cat << EOF > /etc/ssh/sshd_config
# Basic SSH Security Settings
PermitRootLogin no
PasswordAuthentication yes
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 3
AllowUsers $(printf "%s " "${!users[@]}")
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
EOF'

# Restart SSH to apply changes
sudo systemctl restart sshd
sudo systemctl status sshd | grep Active

# === Step 3: Install and Configure Fail2ban ===
echo "[INFO] Installing and configuring fail2ban."
sudo apt update
sudo apt install fail2ban -y

# Configure fail2ban for SSH
sudo bash -c 'cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF'

sudo systemctl enable --now fail2ban
sudo systemctl status fail2ban | grep Active

# === Step 4: Configure firewall for SSH ===
echo "[INFO] Configuring firewall for SSH..."
sudo ufw allow from 192.168.21.0/24 to any port 22
sudo ufw allow from 172.18.0.0/16 to any port 22

echo "[SUCCESS] SSH setup and user account creation completed successfully."
