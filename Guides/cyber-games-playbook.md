# NCAE Cyber Games - Blue Team Command Playbook

## Pre-Game Setup (Before Event Starts)

### 1. Initial System Security
```bash
# Update all systems
sudo apt update && sudo apt upgrade -y

# Install essential security tools
sudo apt install -y ufw fail2ban snort suricata aide rkhunter lynis auditd tcpdump wireshark

# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow from 192.168.21.0/24
sudo ufw allow from 172.18.0.0/16
sudo ufw enable

# Configure fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
```

### 2. Network Segmentation
```bash
# Run network segmentation script
sudo ./network_segmentation.sh

# Verify VLANs
ip link show | grep vlan
brctl show

# Check firewall rules
sudo iptables -L -n -v
```

### 3. System Monitoring Setup
```bash
# Start monitoring services
sudo systemctl start snort
sudo systemctl start suricata
sudo systemctl start aidecheck.timer

# Monitor logs in real-time
tail -f /var/log/auth.log | grep -i "failed\|error\|warning" &
tail -f /var/log/apache2/error.log | grep -i "error\|warning" &
tail -f /var/log/mysql/error.log | grep -i "error\|warning" &
```

## During Game Monitoring

### 1. Real-time System Monitoring
```bash
# Monitor system processes
top -b -n 1

# Monitor network connections
netstat -tuln

# Monitor failed login attempts
lastb | head -n 20

# Monitor disk usage
df -h
```

### 2. Security Checks
```bash
# Check for rootkits
sudo rkhunter --check

# Check file integrity
sudo aide --check

# Check for suspicious processes
ps aux | grep -i "nmap\|metasploit\|wireshark\|nmap"

# Check for unauthorized users
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

### 3. Network Monitoring
```bash
# Monitor network traffic
sudo tcpdump -i any -w capture.pcap

# Monitor specific ports
sudo tcpdump -i any port 22 or port 80 or port 443 or port 3306

# Check for port scans
sudo tcpdump -i any -n | grep -i "scan\|probe"
```

## Incident Response Commands

### 1. Suspicious Activity Detection
```bash
# Check for failed SSH attempts
grep "Failed password" /var/log/auth.log | tail -n 20

# Check for SQL injection attempts
grep -i "sql\|injection" /var/log/apache2/error.log

# Check for file modification attempts
find /var/www -type f -mtime -1 -ls
```

### 2. Immediate Response Actions
```bash
# Block suspicious IP
sudo iptables -A INPUT -s SUSPICIOUS_IP -j DROP

# Lock compromised account
sudo usermod -L COMPROMISED_USER

# Stop suspicious service
sudo systemctl stop SUSPICIOUS_SERVICE

# Kill suspicious process
sudo kill -9 SUSPICIOUS_PID
```

### 3. Evidence Collection
```bash
# Save system state
sudo ps aux > /var/log/incident/processes.txt
sudo netstat -tuln > /var/log/incident/connections.txt
sudo lsof -i > /var/log/incident/open_ports.txt

# Save logs
sudo cp /var/log/auth.log /var/log/incident/auth.log
sudo cp /var/log/apache2/error.log /var/log/incident/apache.log
```

## Recovery Commands

### 1. Service Recovery
```bash
# Restart critical services
sudo systemctl restart apache2
sudo systemctl restart mysql
sudo systemctl restart sshd

# Verify service status
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status sshd
```

### 2. System Recovery
```bash
# Restore from backup
sudo ./backup-system.sh restore BACKUP_DATE

# Verify system integrity
sudo aide --check

# Reset firewall rules
sudo iptables-restore < /etc/iptables.rules
```

### 3. User Management
```bash
# Reset compromised user password
sudo passwd COMPROMISED_USER

# Remove unauthorized users
sudo userdel UNAUTHORIZED_USER

# Check sudo access
sudo cat /etc/sudoers
```

## Quick Reference Commands

### 1. System Status
```bash
# Check system load
uptime

# Check memory usage
free -m

# Check disk space
df -h

# Check running services
systemctl list-units --type=service --state=running
```

### 2. Network Status
```bash
# Check network interfaces
ip addr show

# Check routing table
ip route show

# Check firewall status
sudo ufw status verbose

# Check open ports
sudo netstat -tuln
```

### 3. Security Status
```bash
# Check fail2ban status
sudo fail2ban-client status

# Check snort alerts
sudo tail -f /var/log/snort/alert

# Check audit logs
sudo ausearch -ts today

# Check file integrity
sudo aide --check
```

## Emergency Contacts
- Team Lead: [Contact Info]
- System Admin: [Contact Info]
- Security Lead: [Contact Info]
- Competition Officials: [Contact Info]

## Notes
- Keep this playbook readily accessible
- Document all commands executed
- Save all evidence collected
- Report incidents immediately
- Maintain communication with team members 