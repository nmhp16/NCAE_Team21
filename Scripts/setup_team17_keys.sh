#!/bin/bash

# SSH Key Setup Script for Team 21
# - Sets up SSH keys for team members
# - Secures SSH by disabling password authentication
# - Restarts SSH service

echo "[+] Starting Team 21 SSH Key Setup..."

# Define Team 21 Members
declare -a TEAM21_USERS=(
    "team21_admin"
    "team21_web"
    "team21_db"
    "team21_dns"
    "team21_ftp"
    "team21_monitor"
    "team21_backup"
)

# Define Public Keys for Team 21 (Replace FAKE_PUB_KEY_HERE with actual keys)
declare -A USER_KEYS
USER_KEYS["team21_admin"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_web"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_db"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_dns"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_ftp"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_monitor"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_backup"]="FAKE_PUB_KEY_HERE"

# Function to create users and set up SSH keys
setup_user() {
    local USERNAME=$1
    local PUB_KEY=${USER_KEYS[$USERNAME]}

    # Create user if not exists
    if ! id "$USERNAME" &>/dev/null; then
        echo "[+] Creating user: $USERNAME"
        useradd -m -s /bin/bash "$USERNAME"
        # Add to sudo group
        usermod -aG sudo "$USERNAME"
    fi

    # Set up SSH directory
    mkdir -p /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh

    # Add public key
    if [[ ! -z "$PUB_KEY" ]] && [[ "$PUB_KEY" != "FAKE_PUB_KEY_HERE" ]]; then
        echo "$PUB_KEY" > /home/$USERNAME/.ssh/authorized_keys
        chmod 600 /home/$USERNAME/.ssh/authorized_keys
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
        echo "[✔] SSH key added for: $USERNAME"
    else
        echo "[⚠] No public key provided for: $USERNAME (Skipping)"
    fi
}

# Loop through each team member and set up keys
for USER in "${TEAM21_USERS[@]}"; do
    setup_user "$USER"
done

# Secure SSH configuration
echo "[+] Securing SSH configuration..."
cat > /etc/ssh/sshd_config << 'EOF'
# Basic SSH Security Settings
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 3
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
EOF

# Configure firewall for SSH
echo "[+] Configuring firewall for SSH..."
ufw allow from 192.168.21.0/24 to any port 22
ufw allow from 172.18.0.0/16 to any port 22

# Restart SSH service
echo "[+] Restarting SSH service..."
systemctl restart sshd

echo "[✔] Team 21 SSH Key Setup Completed!"
