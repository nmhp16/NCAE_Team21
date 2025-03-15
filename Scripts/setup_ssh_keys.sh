#!/bin/bash

echo "[+] Starting SSH Key Setup..."

# Define users (27 scoring users + 7 team members)
declare -a USERS=(
    # 27 Scoring Users (DO NOT REMOVE)
    "camille_jenatzy"
    "gaston_chasseloup"
    "leon_serpollet"
    "william_vanderbilt"
    "henri_fournier"
    "maurice_augieres"
    "arthur_duray"
    "henry_ford"
    "louis_rigolly"
    "pierre_caters"
    "paul_baras"
    "victor_hemery"
    "fred_marriott"
    "lydston_hornsted"
    "kenelm_guinness"
    "rene_thomas"
    "ernest_eldridge"
    "malcolm_campbell"
    "ray_keech"
    "john_cobb"
    "dorothy_levitt"
    "paula_murphy"
    "betty_skelton"
    "rachel_kushner"
    "kitty_oneil"
    "jessi_combs"
    "andy_green"
    
    # 7 Team Members
    "team21_admin"
    "team21_web"
    "team21_db"
    "team21_dns"
    "team21_ftp"
    "team21_monitor"
    "team21_backup"
)

# Define Public Keys
declare -A USER_KEYS

# Competition Scoring Pub
COMPETITION_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcM4aDj8Y4COv+f8bd2WsrIynlbRGgDj2+q9aBeW1Umj5euxnO1vWsjfkpKnyE/ORsI6gkkME9ojAzNAPquWMh2YG+n11FB1iZl2S6yuZB7dkVQZSKpVYwRvZv2RnYDQdcVnX9oWMiGrBWEAi4jxcYykz8nunaO2SxjEwzuKdW8lnnh2BvOO9RkzmSXIIdPYgSf8bFFC7XFMfRrlMXlsxbG3u/NaFjirfvcXKexz06L6qYUzob8IBPsKGaRjO+vEdg6B4lH1lMk1JQ4GtGOJH6zePfB6Gf7rp31261VRfkpbpaDAznTzh7bgpq78E7SenatNbezLDaGq3Zra3j53u7XaSVipkW0S3YcXczhte2J9kvo6u6s094vrcQfB9YigH4KhXpCErFk08NkYAEJDdqFqXIjvzsro+2/EW1KKB9aNPSSM9EZzhYc+cBAl4+ohmEPej1m15vcpw3k+kpo1NC2rwEXIFxmvTme1A2oIZZBpgzUqfmvSPwLXF0EyfN9Lk= SCORING KEY DO NOT REMOVE"
# Assign the competition key to all scoring users
for user in "${USERS[@]:0:27}"; do
    USER_KEYS["$user"]="$COMPETITION_KEY"
done

# 7 Team Members (Manually Add Your Public Keys Here)
USER_KEYS["team21_admin"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_web"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_db"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_dns"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_ftp"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_monitor"]="FAKE_PUB_KEY_HERE"
USER_KEYS["team21_backup"]="FAKE_PUB_KEY_HERE"

# create users and set up keys
setup_user() {
    local USERNAME=$1
    local PUB_KEY=${USER_KEYS[$USERNAME]}

    # Create user if not exists
    if ! id "$USERNAME" &>/dev/null; then
        echo "[+] Creating user: $USERNAME"
        useradd -m -s /bin/bash "$USERNAME"
        
        # Add team members to sudo group
        if [[ "$USERNAME" == team21_* ]]; then
            usermod -aG sudo "$USERNAME"
        fi
    fi

    # Set up SSH directory
    mkdir -p /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh

    # Add pub key
    if [[ ! -z "$PUB_KEY" ]] && [[ "$PUB_KEY" != "FAKE_PUB_KEY_HERE" ]]; then
        echo "$PUB_KEY" > /home/$USERNAME/.ssh/authorized_keys
        chmod 600 /home/$USERNAME/.ssh/authorized_keys
        chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
        echo "[✔] SSH key added for: $USERNAME"
    else
        echo "[⚠] No public key provided for: $USERNAME (Skipping)"
    fi
}

# Loop through each user and set up keys
for USER in "${USERS[@]}"; do
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

echo "[✔] SSH Key Setup Completed!"
