# Team 21 Network Setup Guide

## 1. Configure MikroTik Router

### (a) Set Up Interfaces & IPs
Connect to MikroTik via WinBox or SSH and run the following commands:

```bash
# Assign External IP (WAN Side)
ip address add address=172.18.13.21/16 interface=ether1

# Assign Internal IP (LAN Side)
ip address add address=192.168.21.1/24 interface=ether2

# Enable NAT for Internet Access
ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Enable Forwarding (Internal ↔ External)
ip firewall filter add chain=forward action=accept
```

### (b) Enable DHCP Server
For dynamic IP assignment for internal VMs:

```bash
# Configure DHCP Server
ip dhcp-server add interface=ether2 address-pool=dhcp-pool disabled=no
ip pool add name=dhcp-pool ranges=192.168.21.100-192.168.21.200
ip dhcp-server network add address=192.168.21.0/24 gateway=192.168.21.1 dns-server=192.168.21.12
```

## 2. Configure External Services

### (a) Configure Gravwell (172.18.16.212)
```bash
# Assign static IP
sudo ip addr add 172.18.16.212/16 dev eth0

# Set default gateway to MikroTik router
sudo ip route add default via 172.18.13.21

# Set DNS server
sudo bash -c 'echo "nameserver 192.168.21.12" > /etc/resolv.conf'

# Test connectivity
ping -c 4 172.18.13.21
```

### (b) Configure External Kali (172.18.15.211-216)
```bash
# Assign static IP (example for first Kali)
sudo ip addr add 172.18.15.211/16 dev eth0

# Set default gateway
sudo ip route add default via 172.18.13.21

# Set DNS server
sudo bash -c 'echo "nameserver 192.168.21.12" > /etc/resolv.conf'

# Test connectivity
ping -c 4 172.18.13.21
```

## 3. Configure Internal Services

### (a) Configure Web Server (192.168.21.7)
```bash
# Assign static IP
sudo ip addr add 192.168.21.7/24 dev eth0

# Set default gateway
sudo ip route add default via 192.168.21.1

# Install Apache Web Server
sudo apt update && sudo apt install -y apache2

# Add team identification
echo "team21" | sudo tee /var/www/html/index.html

# Configure SSL (if certbot available)
sudo certbot --apache -d www.team21.com

# Restart web server
sudo systemctl restart apache2

# Allow HTTP/HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### (b) Configure DNS Server (192.168.21.5)
```bash
# Assign static IP
sudo ip addr add 192.168.21.5/24 dev eth0

# Set default gateway
sudo ip route add default via 192.168.21.1

# Install BIND9
sudo apt update && sudo apt install -y bind9

# Configure zones
sudo ./Scripts/dns_setup.sh

# Test DNS service
dig @192.168.21.5 www.team21.com
```

### (c) Configure Database Server (192.168.21.12)
```bash
# Assign static IP
sudo ip addr add 192.168.21.12/24 dev eth0

# Set default gateway
sudo ip route add default via 192.168.21.1

# Install and secure MySQL
sudo apt update && sudo apt install -y mysql-server
sudo ./Scripts/mysql_secure.sh

# Allow MySQL port
sudo ufw allow 3306/tcp
```

### (d) Configure Internal Kali VMs (192.168.21.41-46)
```bash
# Assign static IP (example for first Kali)
sudo ip addr add 192.168.21.41/24 dev eth0

# Set default gateway
sudo ip route add default via 192.168.21.1

# Set DNS server
sudo bash -c 'echo "nameserver 192.168.21.12" > /etc/resolv.conf'

# Test connectivity
ping -c 4 192.168.21.1
```

## 4. Security Setup

### (a) Run Security Scripts
```bash
# Enhanced security measures
sudo ./Scripts/enhanced_security.sh

# Network segmentation
sudo ./Scripts/network_segmentation.sh

# SSH hardening
sudo ./Scripts/ssh_setup.sh

# Setup honeypot
sudo ./Scripts/cowrie_honeypot.sh
```

### (b) Configure Firewall
```bash
# Setup firewall rules
sudo ./Scripts/firewall.sh

# Verify rules
sudo iptables -L -n -v
```

## Quick Links to Playbooks
- [Web & FTP Security](../Guides/web-ftp-playbook.md)
- [MySQL & DNS Security](../Guides/mysql-dns-playbook.md)
- [SSH Hardening](../Guides/ssh-hardening-playbook.md)
- [Router Security](../Guides/router-security-playbook.md)
- [Honeypot Monitoring](../Guides/honeypot-playbook.md)
- [Red Team Detection](../Guides/red-team-detection.md)
- [Cyber Games Main Guide](../Guides/cyber-games-playbook.md)
- [Backup & Recovery](../Guides/backup-recovery-playbook.md)
- [System Monitoring](../Guides/monitoring-playbook.md)

## Important Notes
1. All systems must use static IPs as assigned
2. Test connectivity after each configuration
3. Verify DNS resolution works correctly
4. Check all security measures are active
5. Monitor logs continuously
6. Keep backups current
7. Document any changes made
8. Test all services after updates