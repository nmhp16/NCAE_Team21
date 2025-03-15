#  Cowrie SSH Honeypot Playbook

##  Objective
Deploy a Honeypot quickly to distract attackers.

##  Step-by-Step Cowrie Setup:

### **Step 1: Install Cowrie**
`git clone https://github.com/cowrie/cowrie.git cd cowrie sudo pip install -r requirements.txt`

### **Step 2: Start Cowrie**
`sudo bin/cowrie start`


## Important Notes:
- **Logs:** `~/cowrie/logs`
- **Restart Cowrie:** `sudo bin/cowrie restart`

## ⚠ Troubleshooting:
- If Cowrie doesn't start, verify dependencies: Python installed correctly?

## Honeypot Monitoring Guide

### 1. Real-time Attack Monitoring
```bash
# Monitor SSH login attempts
sudo tail -f /var/log/cowrie/cowrie.log | grep "login attempt"

# Check for command execution
sudo tail -f /var/log/cowrie/cowrie.log | grep "Command found"

# Monitor file downloads
sudo tail -f /var/log/cowrie/cowrie.log | grep "File download"

# Check for shell commands
sudo tail -f /var/log/cowrie/cowrie.log | grep "Command found"
```

### 2. Attack Analysis
```bash
# Count unique attacking IPs
sudo awk '{print $3}' /var/log/cowrie/cowrie.log | sort | uniq -c | sort -nr

# List common usernames tried
sudo awk '{print $5}' /var/log/cowrie/cowrie.log | sort | uniq -c | sort -nr

# Check for common attack patterns
sudo grep -i "password\|root\|admin" /var/log/cowrie/cowrie.log

# Monitor for suspicious commands
sudo grep -i "wget\|curl\|chmod\|chown" /var/log/cowrie/cowrie.log
```

### 3. Honeypot Protection
```bash
# Block attacking IPs
sudo iptables -A INPUT -s ATTACKER_IP -j DROP

# Update honeypot configuration
sudo systemctl restart cowrie

# Check honeypot status
sudo systemctl status cowrie

# Monitor honeypot resources
sudo ps aux | grep cowrie
```

## Evidence Collection

### 1. Log Collection
```bash
# Save honeypot logs
sudo cp /var/log/cowrie/cowrie.log /var/log/incident/honeypot.log

# Save downloaded files
sudo cp /var/lib/cowrie/downloads/* /var/log/incident/downloads/

# Save command history
sudo cp /var/lib/cowrie/tty/* /var/log/incident/tty/

# Save configuration
sudo cp /etc/cowrie/cowrie.cfg /var/log/incident/
```

### 2. Attack Analysis
```bash
# Generate attack summary
sudo awk '{print $3}' /var/log/cowrie/cowrie.log | sort | uniq -c | sort -nr > /var/log/incident/attacker_ips.txt

# List attempted usernames
sudo awk '{print $5}' /var/log/cowrie/cowrie.log | sort | uniq -c | sort -nr > /var/log/incident/attempted_users.txt

# Extract suspicious commands
sudo grep -i "wget\|curl\|chmod\|chown" /var/log/cowrie/cowrie.log > /var/log/incident/suspicious_commands.txt

# Save file download history
sudo ls -l /var/lib/cowrie/downloads/ > /var/log/incident/downloaded_files.txt
```

## Quick Response Actions

### 1. Immediate Actions
```bash
# Block attacking IP
sudo iptables -A INPUT -s ATTACKER_IP -j DROP

# Restart honeypot
sudo systemctl restart cowrie

# Clear downloaded files
sudo rm -rf /var/lib/cowrie/downloads/*

# Update firewall rules
sudo iptables-save > /etc/iptables.rules
```

### 2. Analysis Actions
```bash
# Check for malware
sudo clamscan /var/lib/cowrie/downloads/

# Analyze suspicious files
sudo file /var/lib/cowrie/downloads/*

# Check file hashes
sudo md5sum /var/lib/cowrie/downloads/*

# Monitor network connections
sudo netstat -tuln | grep 2222
```

## Prevention Commands

### 1. Honeypot Hardening
```bash
# Update honeypot
sudo apt update && sudo apt upgrade cowrie

# Secure configuration
sudo sed -i 's/port = 2222/port = 2222\nbind_address = 0.0.0.0/' /etc/cowrie/cowrie.cfg

# Set secure permissions
sudo chown -R cowrie:cowrie /var/lib/cowrie
sudo chmod 750 /var/lib/cowrie

# Enable logging
sudo sed -i 's/logfile = cowrie.log/logfile = \/var\/log\/cowrie\/cowrie.log/' /etc/cowrie/cowrie.cfg
```

### 2. Network Protection
```bash
# Configure firewall
sudo ufw allow 2222/tcp
sudo ufw allow from 192.168.21.0/24 to any port 2222

# Set up fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban

# Monitor connections
sudo tcpdump -i any port 2222 -n
```

## Notes
- Monitor honeypot logs continuously
- Document all suspicious activities
- Save evidence for analysis
- Report incidents immediately
- Keep honeypot updated
- Regular log rotation
- Monitor system resources
- Backup important data

**END OF PLAYBOOK**

