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

Stay secure and play smart! 🚀