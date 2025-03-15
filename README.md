# NCAE Cyber Games 2025 - Blue Team 21 Repository

This repository contains the official scripts and playbooks used by our team during the NCAE Cyber Games. These scripts will help us quickly secure and configure our network and servers.

## 🚨 Important: Read Before Executing Any Script
- Always carefully review each script before executing.
- Certain scripts require manual changes (such as usernames, passwords, and IP addresses). Instructions for required edits are clearly marked inside each script.

### 🔹 Important Guidelines Before Running Any Script:
- Verify usernames and passwords carefully.
- Double-check IP addresses and network configurations.
- Run each script only on its designated server.
- Check the **"When and Where to Use"** instructions clearly stated below before executing each script.

## 📌 Quick Links to Each Script and Playbook
- **SSH Setup Script** (`ssh_setup.sh`)
- **Firewall Setup Script** (`firewall.sh`)
- **DNS Server Setup Script** (`dns_setup.sh`)
- **Apache Web SSL Setup Script** (`apache_ssl.sh`)
- **FTP Server Setup Script** (`ftp_setup.sh`)
- **Cowrie Honeypot Setup Script** (`cowrie_honeypot.sh`)
- **MySQL Secure Setup Script** (`mysql_secure.sh`)

## 🚀 Execution Instructions (Common for All Scripts):
1. Make each script executable before running:
   ```bash
   chmod +x script_name.sh
   ```
2. Run each script with sudo privileges:
   ```bash
   sudo ./script_name.sh
   ```
3. **Review script-specific documentation carefully before executing.**

---

## 🔐 SSH Setup Script (`ssh_setup.sh`)
**Purpose:** Quickly creates secure user accounts for your entire team and immediately locks down SSH by disabling root login, enforcing user permissions, and installing `fail2ban`.

🚨 **Important:** You must edit the usernames and passwords in the script (`ssh_setup.sh`) before executing it. 

Example section you must edit:
```bash
["team21user1"]="NewStrongPassword1"
["team21user2"]="NewStrongPassword2"
```
Replace `team21user1` and `team21user2` with actual usernames and set strong, unique passwords for each team member.

### How to Execute (`ssh_setup.sh`):
1. **Set permissions (make executable):**
   ```bash
   chmod +x ssh_setup.sh
   ```
2. **Run as root (required):**
   ```bash
   sudo ./ssh_setup.sh
   ```

### ✅ After script runs:
- Users will be created and passwords set.
- Root login via SSH will be disabled for security.
- `fail2ban` is installed and running.

---

# Firewall Setup and Security Scripts

## Firewall Setup Script (`firewall.sh`)
**Purpose:** Sets up a basic firewall on Linux servers to protect against unauthorized access by allowing only essential services like SSH, HTTP, and HTTPS.

### Important:
- This script is for Linux servers only (e.g., Web, Database, DNS, FTP servers).
- **Do not** run this script on the MikroTik router.

### Services Allowed (by default):
- **SSH** (port 22)
- **HTTP** (port 80)
- **HTTPS** (port 443)

### Execution Instructions:
```bash
chmod +x firewall.sh
sudo ./firewall.sh
```

### After Execution:
- Firewall (`ufw`) will be enabled.
- Default rules applied (deny all incoming, allow essential services).
- Verify rules using:
```bash
sudo ufw status verbose
```

---
## DNS Server Script (`dns_setup.sh`)
**Purpose:** Installs and securely configures a DNS server (BIND9). This script should only be run on the **DNS Server** (e.g., `192.168.t.8`).

### What it Does:
- Installs BIND9 DNS server software.
- Restricts DNS queries to the internal network (`192.168.0.0/24`).
- Disables DNS recursion and zone transfers for security.

### Execution Instructions:
```bash
chmod +x dns_setup.sh
sudo ./dns_setup.sh
```

### After Execution:
- Your DNS service is securely running and protected against external queries.

---
## Apache SSL Setup Script (`apache_ssl.sh`)
**Purpose:** Installs Apache, enables SSL, and generates a Certificate Signing Request (CSR) for an official SSL certificate.

### When and Where to Use:
- Only use on the **Web Server** (e.g., `192.168.t.5`).
- Run **once** at competition start before scoring checks.

### Execution Instructions:
```bash
chmod +x apache_ssl.sh
sudo ./apache_ssl.sh
```

### After Execution:
- Apache installed with SSL enabled.
- CSR (`team.csr`) generated—upload to CA server.
- Manually configure SSL once the certificate (`team.crt`) is received.

---
## FTP Server Setup Script (`ftp_setup.sh`)
**Purpose:** Installs and securely configures an FTP server (`vsftpd`), disabling anonymous access and restricting users securely.

### When and Where to Use:
- Run **only** on a dedicated **FTP server**.
- Execute **once** after initial setup.

### Execution Instructions:
```bash
chmod +x ftp_setup.sh
sudo ./ftp_setup.sh
```

### Security Configurations Applied:
- **Anonymous FTP login disabled** (`anonymous_enable=NO`).
- **Secure local-user login enabled** with write permissions.
- **User restrictions enforced** (`chroot_local_user=YES`).

---
## Cowrie Honeypot Setup Script (`cowrie_honeypot.sh`)
**Purpose:** Deploys a honeypot to attract and log malicious activity, imitating an SSH server.

### When and Where to Use:
- **Run only** on an **isolated honeypot server** (e.g., `172.18.13.100`).
- Execute **before** opening external firewall rules.

### Execution Instructions:
```bash
chmod +x cowrie_honeypot.sh
sudo ./cowrie_honeypot.sh
```

### What this script does:
- Installs required dependencies.
- Clones Cowrie repository.
- Sets up a virtual environment and installs dependencies.
- Starts the Cowrie honeypot service.

### Post-installation Checks:
- Verify that the honeypot is running:
```bash
pgrep -f "twistd -n cowrie"
```
- Check logs:
```bash
cat ~/cowrie/var/log/cowrie/cowrie.log
```
- Manage Cowrie manually:
```bash
cd ~/cowrie
sudo bin/cowrie restart
```

### MikroTik Router Firewall Rules to Redirect Attackers:
```bash
/ip firewall nat add chain=dstnat protocol=tcp dst-port=22 action=dst-nat to-addresses=172.18.13.100
```

### Important Security Note:
- **Do NOT** run this on production servers.
- **Ensure** the honeypot is isolated from the real network.

---
## MySQL Secure Setup Script (`mysql_secure.sh`)
**Purpose:** Securely installs and configures MySQL, removing insecure defaults and hardening security settings.

### When and Where to Use:
- **Run only** on a dedicated **MySQL Database Server** (e.g., `192.168.t.12`).
- Execute **immediately** after setup.

### Execution Instructions:
```bash
chmod +x mysql_secure.sh
sudo ./mysql_secure.sh
```

### What this script does:
- Installs MySQL server.
- Runs `mysql_secure_installation` to:
  - Set a **strong root password**.
  - Remove **anonymous users**.
  - Disable **remote root logins**.
  - Delete **default/test databases**.
  - Reload MySQL privileges.

### After Execution Checklist:
- **MySQL installed and running**.
- **Root password set securely**.
- **Remote root access disabled**.
- **Anonymous users removed**.
- **Test databases deleted**.

### Check MySQL Status:
```bash
sudo systemctl status mysql
```

### Login to MySQL:
```bash
sudo mysql -u root -p
```

### Troubleshooting:
- Forgot MySQL root password? Reset with:
```bash
sudo mysqladmin -u root password "YourNewSecurePassword"
```
- **Remote root login is disabled** for security purposes. Use SSH or local access.

---