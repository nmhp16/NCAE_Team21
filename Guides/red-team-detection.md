# Red Team Attack Detection Guide

## Common Attack Patterns and Detection Commands

### 1. Port Scanning Detection
```bash
# Monitor for SYN scans
sudo tcpdump -i any 'tcp[tcpflags] & (tcp-syn) != 0 and tcp[tcpflags] & (tcp-ack) = 0'

# Monitor for connection attempts
sudo netstat -n | grep ESTABLISHED | awk '{print $5}' | sort | uniq -c | sort -nr

# Check for failed connections
sudo tail -f /var/log/auth.log | grep "Failed password"
```

### 2. Brute Force Detection
```bash
# Check for multiple failed login attempts
sudo grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# Monitor fail2ban status
sudo fail2ban-client status sshd

# Check for rapid connection attempts
sudo tail -f /var/log/auth.log | grep "Connection closed"
```

### 3. SQL Injection Detection
```bash
# Monitor MySQL error logs
sudo tail -f /var/log/mysql/error.log | grep -i "error\|warning"

# Check Apache error logs
sudo tail -f /var/log/apache2/error.log | grep -i "sql\|injection\|error"

# Monitor failed database connections
sudo tail -f /var/log/mysql/error.log | grep "Access denied"
```

### 4. File System Attacks
```bash
# Monitor for file changes
sudo aide --check

# Check for modified system files
sudo find /etc -type f -mtime -1 -ls

# Monitor web directory changes
sudo find /var/www -type f -mtime -1 -ls
```

### 5. Privilege Escalation Detection
```bash
# Check for sudo usage
sudo grep sudo /var/log/auth.log

# Monitor for new users
sudo tail -f /etc/passwd

# Check for modified sudoers
sudo ls -l /etc/sudoers
```

### 6. Network Traffic Analysis
```bash
# Monitor for unusual connections
sudo netstat -tuln | grep -v "127.0.0.1"

# Check for data exfiltration
sudo tcpdump -i any -n | grep -i "outbound\|external"

# Monitor DNS queries
sudo tcpdump -i any -n udp port 53
```

### 7. Process Monitoring
```bash
# Check for suspicious processes
sudo ps aux | grep -i "nmap\|metasploit\|wireshark"

# Monitor for new processes
sudo watch -n 1 'ps aux | grep -v grep'

# Check for hidden processes
sudo ps -ef | grep -v grep
```

### 8. Service Manipulation
```bash
# Monitor service status changes
sudo systemctl list-units --type=service --state=running

# Check for stopped services
sudo systemctl list-units --type=service --state=inactive

# Monitor service logs
sudo journalctl -u apache2 -f
```

### 9. User Account Monitoring
```bash
# Check for new users
sudo awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Monitor failed login attempts
sudo lastb | head -n 20

# Check for locked accounts
sudo passwd -S -a
```

### 10. System Resource Monitoring
```bash
# Monitor CPU usage
top -b -n 1

# Check memory usage
free -m

# Monitor disk I/O
iostat -x 1
```

## Quick Response Commands

### 1. Blocking Attacks
```bash
# Block IP address
sudo iptables -A INPUT -s ATTACKER_IP -j DROP

# Block port
sudo iptables -A INPUT -p tcp --dport PORT_NUMBER -j DROP

# Block network range
sudo iptables -A INPUT -s NETWORK_RANGE -j DROP
```

### 2. Account Security
```bash
# Lock user account
sudo usermod -L USERNAME

# Force password change
sudo chage -d 0 USERNAME

# Remove user
sudo userdel -r USERNAME
```

### 3. Service Protection
```bash
# Stop service
sudo systemctl stop SERVICE_NAME

# Disable service
sudo systemctl disable SERVICE_NAME

# Restart service
sudo systemctl restart SERVICE_NAME
```

### 4. Evidence Collection
```bash
# Save process list
sudo ps aux > /var/log/incident/processes.txt

# Save network connections
sudo netstat -tuln > /var/log/incident/connections.txt

# Save system logs
sudo cp /var/log/auth.log /var/log/incident/auth.log
```

## Common Red Team Tools Detection

### 1. Network Tools
```bash
# Detect nmap
sudo tcpdump -i any -n | grep -i "nmap"

# Detect metasploit
sudo ps aux | grep -i "metasploit"

# Detect wireshark
sudo ps aux | grep -i "wireshark"
```

### 2. Exploitation Tools
```bash
# Check for common exploit files
sudo find / -type f -name "*.exe" -o -name "*.sh" -o -name "*.py" -mtime -1

# Monitor for suspicious scripts
sudo find / -type f -executable -mtime -1

# Check for modified binaries
sudo find /usr/bin -type f -mtime -1
```

### 3. Password Cracking
```bash
# Monitor for password attempts
sudo tail -f /var/log/auth.log | grep "Failed password"

# Check for brute force attempts
sudo fail2ban-client status

# Monitor for password changes
sudo tail -f /var/log/auth.log | grep "password changed"
```

## Notes
- Keep logs of all suspicious activities
- Document all response actions
- Save evidence for analysis
- Report incidents to team lead
- Maintain communication with team members 