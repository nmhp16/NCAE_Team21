# SSH Hardening Guide

## SSH Configuration Monitoring

### 1. SSH Service Monitoring
```bash
# Check SSH service status
sudo systemctl status sshd

# Monitor SSH connections
sudo netstat -tuln | grep 22

# Check SSH logs
sudo tail -f /var/log/auth.log | grep sshd

# Monitor failed login attempts
sudo tail -f /var/log/auth.log | grep "Failed password"
```

### 2. SSH Security Checks
```bash
# Check SSH configuration
sudo sshd -T

# Verify SSH key permissions
sudo ls -la ~/.ssh/

# Check for root login attempts
sudo grep "root" /var/log/auth.log | grep sshd

# Monitor for brute force attempts
sudo fail2ban-client status sshd
```

### 3. SSH Protection
```bash
# Block attacking IPs
sudo iptables -A INPUT -s ATTACKER_IP -p tcp --dport 22 -j DROP

# Update SSH configuration
sudo systemctl restart sshd

# Check SSH status
sudo systemctl status sshd

# Monitor SSH processes
sudo ps aux | grep sshd
```

## Quick Response Actions

### 1. SSH Response
```bash
# Restart SSH service
sudo systemctl restart sshd

# Check SSH logs
sudo tail -n 50 /var/log/auth.log

# Verify SSH configuration
sudo sshd -t

# Check fail2ban status
sudo fail2ban-client status
```

### 2. Security Response
```bash
# Check for unauthorized keys
sudo find / -name "authorized_keys" -type f -ls

# Verify SSH users
sudo grep -i "sshd" /etc/passwd

# Check sudo access
sudo cat /etc/sudoers

# Monitor system logs
sudo journalctl -u sshd -f
```

## Evidence Collection

### 1. SSH Evidence
```bash
# Save SSH logs
sudo cp /var/log/auth.log /var/log/incident/ssh_auth.log

# Save SSH configuration
sudo cp /etc/ssh/sshd_config /var/log/incident/

# Save authorized keys
sudo cp ~/.ssh/authorized_keys /var/log/incident/

# Save system logs
sudo cp /var/log/syslog /var/log/incident/
```

### 2. Security Evidence
```bash
# Save user list
sudo cat /etc/passwd > /var/log/incident/users.txt

# Save sudo access
sudo cat /etc/sudoers > /var/log/incident/sudoers.txt

# Save SSH processes
sudo ps aux | grep sshd > /var/log/incident/ssh_processes.txt

# Save network connections
sudo netstat -tuln | grep 22 > /var/log/incident/ssh_connections.txt
```

## Prevention Commands

### 1. SSH Hardening
```bash
# Disable root login
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Set secure permissions
sudo chmod 700 ~/.ssh
sudo chmod 600 ~/.ssh/authorized_keys

# Configure SSH timeout
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/sshd_config
```

### 2. System Security
```bash
# Configure fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban

# Set up firewall rules
sudo ufw allow ssh
sudo ufw allow from 192.168.21.0/24 to any port 22

# Monitor connections
sudo tcpdump -i any port 22 -n
```

## Additional Security Measures

### 1. Key Management
```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "team21_admin"

# Copy public key
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host

# Set key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### 2. Access Control
```bash
# Allow specific users
sudo sed -i 's/#AllowUsers/AllowUsers team21_admin team21_web team21_db/' /etc/ssh/sshd_config

# Set login grace time
sudo sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/' /etc/ssh/sshd_config

# Set max sessions
sudo sed -i 's/#MaxSessions 10/MaxSessions 2/' /etc/ssh/sshd_config

# Set max auth tries
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
```

## Notes
- Monitor SSH logs continuously
- Document all suspicious activities
- Save evidence for analysis
- Report incidents immediately
- Keep SSH updated
- Regular key rotation
- Monitor system resources
- Backup configurations




