#  MikroTik Router Security Playbook

##  Objective
Quickly secure and configure MikroTik Router at competition start.

##  Default Credentials
- Username: `admin`
- Password: *(default blank)*

##  Step-by-Step Instructions:

### **Step 1: Access Router**
- Open browser, enter router IP (usually `172.18.0.1`).
- Log in with default credentials.

### **Step 2: Immediately Change Password**
Go to Terminal:
`set admin password=YourStrongPassword`


### **Step 3: Configure Firewall Rules (Critical!)**
Go to Terminal:
`/ip firewall filter add chain=input protocol=tcp dst-port=22,80,443 action=accept comment="Allow SSH, HTTP, HTTPS" /ip firewall filter add chain=input action=drop comment="Block All Other Traffic"`


### **Step 4: Configure NAT (Network Address Translation)**
`/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1`


### **Step 5: Verify Settings**
`/ip firewall filter print /ip firewall nat print`


### 🚩 **Step 6: Backup Configuration**
/system backup save name=team2-router-backup


##  Troubleshooting & Common Issues:
- Locked out accidentally? Reset and restart quickly.
- Check firewall rules carefully if network not reachable.

**END OF PLAYBOOK**

# Router Security Monitoring Guide

## Network Traffic Monitoring

### 1. Traffic Analysis
```bash
# Monitor network interfaces
sudo tcpdump -i any -n

# Check for suspicious traffic patterns
sudo tcpdump -i any -n | grep -i "scan\|probe\|attack"

# Monitor specific protocols
sudo tcpdump -i any -n tcp port 80 or tcp port 443 or tcp port 22

# Check for large data transfers
sudo tcpdump -i any -n -w capture.pcap
```

### 2. Network Statistics
```bash
# View network connections
sudo netstat -tuln

# Check routing table
sudo ip route show

# Monitor bandwidth usage
sudo iftop -i any

# Check interface statistics
sudo ifconfig -a
```

### 3. Firewall Monitoring
```bash
# View firewall rules
sudo iptables -L -n -v

# Check NAT rules
sudo iptables -t nat -L -n -v

# Monitor dropped packets
sudo iptables -L -n -v | grep DROP

# Check connection tracking
sudo cat /proc/net/nf_conntrack
```

## Security Checks

### 1. Router Configuration
```bash
# Check router status
sudo systemctl status network-manager

# Verify network configuration
sudo cat /etc/netplan/*.yaml

# Check DNS settings
sudo cat /etc/resolv.conf

# View network interfaces
sudo ip link show
```

### 2. Security Monitoring
```bash
# Check for unauthorized access
sudo last | grep -v "reboot"

# Monitor system logs
sudo tail -f /var/log/syslog | grep -i "error\|warning"

# Check for suspicious processes
sudo ps aux | grep -i "nmap\|wireshark\|tcpdump"

# Monitor system resources
sudo top -b -n 1
```

### 3. Network Protection
```bash
# Block suspicious IPs
sudo iptables -A INPUT -s ATTACKER_IP -j DROP

# Block port scanning
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Protect against SYN floods
sudo iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
sudo iptables -A INPUT -p tcp --syn -j DROP

# Block ICMP floods
sudo iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
sudo iptables -A INPUT -p icmp -j DROP
```

## Quick Response Actions

### 1. Network Response
```bash
# Restart network services
sudo systemctl restart network-manager

# Reset firewall rules
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

# Restore default policies
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Reapply security rules
sudo ./firewall.sh
```

### 2. System Response
```bash
# Check system integrity
sudo rkhunter --check

# Update system
sudo apt update && sudo apt upgrade -y

# Check for rootkits
sudo chkrootkit

# Monitor system logs
sudo journalctl -f
```

## Evidence Collection

### 1. Network Evidence
```bash
# Save network configuration
sudo ip addr show > /var/log/incident/network_config.txt
sudo ip route show > /var/log/incident/routing_table.txt

# Save firewall rules
sudo iptables-save > /var/log/incident/firewall_rules.txt

# Save network statistics
sudo netstat -tuln > /var/log/incident/connections.txt
sudo ifconfig -a > /var/log/incident/interfaces.txt
```

### 2. System Evidence
```bash
# Save system logs
sudo cp /var/log/syslog /var/log/incident/
sudo cp /var/log/auth.log /var/log/incident/

# Save process list
sudo ps aux > /var/log/incident/processes.txt

# Save network captures
sudo cp capture.pcap /var/log/incident/
```

## Prevention Commands

### 1. Router Hardening
```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# Secure network configuration
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# Set secure permissions
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 600 /etc/network/interfaces
```

### 2. Network Security
```bash
# Configure secure DNS
sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'

# Enable TCP SYN cookies
sudo sed -i 's/#net.ipv4.tcp_syncookies=1/net.ipv4.tcp_syncookies=1/' /etc/sysctl.conf

# Disable ICMP redirects
sudo sed -i 's/#net.ipv4.conf.all.accept_redirects=0/net.ipv4.conf.all.accept_redirects=0/' /etc/sysctl.conf
```

## Notes
- Monitor network traffic continuously
- Document all suspicious activities
- Save evidence for analysis
- Report incidents immediately
- Keep system updated
- Regular security audits
- Monitor system resources
- Backup configurations


