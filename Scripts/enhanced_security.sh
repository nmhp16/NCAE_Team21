#!/bin/bash

# Enhanced Security Setup Script for Blue Team
# NCAE Cyber Games Competition
# Run this script on all critical servers

echo "[START] Implementing Enhanced Security Measures"

# === Step 1: Install Security Tools ===
echo "[INFO] Installing security tools..."
sudo apt update
sudo apt install -y aide aide-common snort suricata fail2ban rkhunter lynis auditd

# === Step 2: Configure File Integrity Monitoring (AIDE) ===
echo "[INFO] Setting up AIDE..."
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
sudo systemctl enable aidecheck.timer
sudo systemctl start aidecheck.timer

# === Step 3: Configure Snort IDS ===
echo "[INFO] Configuring Snort..."
sudo cp /etc/snort/snort.conf /etc/snort/snort.conf.backup
sudo bash -c 'cat << EOF > /etc/snort/snort.conf
var HOME_NET 192.168.21.0/24
var EXTERNAL_NET 172.18.0.0/16
var RULE_PATH /etc/snort/rules
var SO_RULE_PATH /etc/snort/so_rules
var PREPROC_RULE_PATH /etc/snort/preproc_rules
var WHITE_LIST_PATH /etc/snort/rules/white_list.rules
var BLACK_LIST_PATH /etc/snort/rules/black_list.rules
include \$RULE_PATH/local.rules
EOF'

# === Step 4: Enhanced Fail2ban Configuration ===
echo "[INFO] Configuring enhanced Fail2ban..."
sudo bash -c 'cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = iptables-multiport

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 3

[vsftpd]
enabled = true
port = ftp,ftp-data,ftps,ftps-data
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3

[mysql-auth]
enabled = true
port = 3306
filter = mysql-auth
logpath = /var/log/mysql/error.log
maxretry = 3
EOF'

# === Step 5: Configure Audit System ===
echo "[INFO] Setting up audit system..."
sudo bash -c 'cat << EOF > /etc/audit/auditd.conf
log_file = /var/log/audit/audit.log
log_format = RAW
log_group = root
priority_boost = 4
flush = INCREMENTAL
freq = 20
num_logs = 5
disp_qos = lossy
dispatcher = /sbin/audispd
name_format = NONE
max_log_file = 6
max_log_file_action = ROTATE
space_left = 75
space_left_action = SYSLOG
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
EOF'

# === Step 6: Set up Rootkit Detection ===
echo "[INFO] Configuring rkhunter..."
sudo rkhunter --update
sudo rkhunter --propupd

# === Step 7: Enhanced Firewall Rules ===
echo "[INFO] Setting up enhanced firewall rules..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow from 192.168.21.0/24 to any
sudo ufw allow from 172.18.0.0/16 to any

# Rate limiting for SSH
sudo ufw limit ssh/tcp

# === Step 8: Set up Logging ===
echo "[INFO] Configuring enhanced logging..."
sudo bash -c 'cat << EOF > /etc/rsyslog.d/99-security.conf
# Log all authentication attempts
auth.* /var/log/auth.log

# Log all sudo commands
local2.* /var/log/sudo.log

# Log all failed login attempts
authpriv.* /var/log/secure

# Log all system messages
*.info /var/log/messages

# Log all mail messages
mail.* /var/log/mail.log

# Log all cron jobs
cron.* /var/log/cron.log
EOF'

# === Step 9: Set up Password Policies ===
echo "[INFO] Configuring password policies..."
sudo bash -c 'cat << EOF > /etc/security/pwquality.conf
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
minclass = 4
EOF'

# === Step 10: Configure Sudo Logging ===
echo "[INFO] Setting up sudo logging..."
sudo bash -c 'cat << EOF > /etc/sudoers.d/99-security
Defaults logfile="/var/log/sudo.log"
Defaults log_input,log_output
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF'

# === Step 11: Set up Account Lockout Policies ===
echo "[INFO] Configuring account lockout policies..."
sudo bash -c 'cat << EOF > /etc/security/faillock.conf
deny = 5
unlock_time = 900
fail_interval = 900
EOF'

# === Step 12: Create Honeytokens ===
echo "[INFO] Creating honeytokens..."
sudo mkdir -p /opt/honeytokens
sudo bash -c 'cat << EOF > /opt/honeytokens/fake_credentials.txt
FAKE_DB_USER=admin
FAKE_DB_PASS=team21_fake_$(openssl rand -hex 16)
FAKE_API_KEY=team21_fake_$(openssl rand -hex 32)
FAKE_SSH_KEY=team21_fake_$(openssl rand -hex 64)
EOF'
sudo chmod 644 /opt/honeytokens/fake_credentials.txt

# === Step 13: Enable and Start Services ===
echo "[INFO] Enabling and starting security services..."
sudo systemctl enable snort
sudo systemctl enable suricata
sudo systemctl enable auditd
sudo systemctl enable fail2ban
sudo systemctl start snort
sudo systemctl start suricata
sudo systemctl start auditd
sudo systemctl start fail2ban

# === Step 14: Set up Daily Security Checks ===
echo "[INFO] Setting up daily security checks..."
sudo bash -c 'cat << EOF > /etc/cron.daily/security-checks
#!/bin/bash
/usr/bin/rkhunter --check
/usr/bin/lynis audit system
/usr/bin/aide --check
/usr/bin/fail2ban-client status
/usr/bin/ufw status
EOF'
sudo chmod +x /etc/cron.daily/security-checks

echo "[COMPLETE] Enhanced security measures have been implemented!"
echo "[INFO] Please review the logs and adjust configurations as needed."
echo "[INFO] Remember to regularly update security tools and rules." 