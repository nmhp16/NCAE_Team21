#!/bin/bash

# MikroTik Router Setup Commands
# Note: Run these commands in MikroTik terminal after SSH login

# 1. Initial Access
echo "Initial SSH access:"
echo "ssh admin@192.168.21.1"
echo "Default password: abc123"

# 2. Basic System Commands
echo "
# Change admin password
/user set admin password=Team21SecurePass123!

# Set system identity
/system identity set name=Team21-Router

# Set timezone
/system clock set time-zone-name=America/New_York
"

# 3. Interface Setup
echo "
# Configure interfaces
/interface set ether1 name=external-wan comment=\"External WAN Interface\"
/interface set ether2 name=internal-lan comment=\"Internal LAN Interface\"

# Configure IP addresses (External and Internal)
/ip address add address=172.18.13.21/16 interface=ether1
/ip address add address=192.168.21.1/24 interface=ether2

# Enable forwarding between interfaces
/ip firewall filter add chain=forward action=accept comment=\"Allow forwarding between interfaces\"
"

# 4. NAT Configuration
echo "
# Setup NAT for internal network
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment=\"NAT for Internal Network\"
"

# 5. DHCP Server Setup
echo "
# Setup DHCP server for internal network
/ip pool add name=dhcp_pool1 ranges=192.168.21.100-192.168.21.200
/ip dhcp-server network add address=192.168.21.0/24 gateway=192.168.21.1 dns-server=192.168.21.12
/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool1 disabled=no
"

# 6. Basic Firewall Rules
echo "
# Clear existing rules
/ip firewall filter remove [find]

# Default policies
/ip firewall filter add chain=input action=accept connection-state=established,related comment=\"Allow Established Connections\"
/ip firewall filter add chain=input action=accept protocol=icmp comment=\"Allow ICMP\"

# Allow SSH from internal network
/ip firewall filter add chain=input protocol=tcp dst-port=22 src-address=192.168.21.0/24 action=accept comment=\"Allow SSH from Internal\"

# Allow essential services
/ip firewall filter add chain=input protocol=tcp dst-port=80 action=accept comment=\"Allow HTTP\"
/ip firewall filter add chain=input protocol=tcp dst-port=443 action=accept comment=\"Allow HTTPS\"
/ip firewall filter add chain=input protocol=udp dst-port=53 action=accept comment=\"Allow DNS\"

# Port forwarding for services
/ip firewall nat add chain=dstnat dst-port=80 protocol=tcp to-address=192.168.21.7 to-port=80 action=dst-nat comment=\"Forward HTTP to Web Server\"
/ip firewall nat add chain=dstnat dst-port=443 protocol=tcp to-address=192.168.21.7 to-port=443 action=dst-nat comment=\"Forward HTTPS to Web Server\"
/ip firewall nat add chain=dstnat dst-port=53 protocol=udp to-address=192.168.21.5 to-port=53 action=dst-nat comment=\"Forward DNS to DNS Server\"

# Drop everything else
/ip firewall filter add chain=input action=drop comment=\"Drop all other input\"
"

# 7. DNS Settings
echo "
# Set DNS servers
/ip dns set servers=192.168.21.12,8.8.8.8
/ip dns set allow-remote-requests=yes
"

# 8. Security Features
echo "
# Enable SSH strong crypto
/ip ssh set strong-crypto=yes

# Disable unused services
/ip service disable telnet
/ip service disable ftp
/ip service disable www
/ip service disable api
/ip service disable api-ssl

# Set SSH port
/ip service set ssh port=22
"

# 9. Anti-Brute Force Protection
echo "
# Block common attack ports
/ip firewall filter add chain=input protocol=tcp dst-port=23,25,3389 action=drop comment=\"Block Common Attack Ports\"

# Rate limiting for SSH
/ip firewall filter add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list=ssh_blacklist action=drop comment=\"Drop Blacklisted SSH\"
/ip firewall filter add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list=ssh_stage3 action=add-src-to-address-list address-list=ssh_blacklist address-list-timeout=1d comment=\"Add to Blacklist\"
/ip firewall filter add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list=ssh_stage2 action=add-src-to-address-list address-list=ssh_stage3 address-list-timeout=1m comment=\"Add to Stage 3\"
/ip firewall filter add chain=input protocol=tcp dst-port=22 connection-state=new src-address-list=ssh_stage1 action=add-src-to-address-list address-list=ssh_stage2 address-list-timeout=1m comment=\"Add to Stage 2\"
/ip firewall filter add chain=input protocol=tcp dst-port=22 connection-state=new action=add-src-to-address-list address-list=ssh_stage1 address-list-timeout=1m comment=\"Add to Stage 1\"
"

# 10. Backup Configuration
echo "
# Create backup
/system backup save name=team21_config

# Add daily backup scheduler
/system scheduler add name=daily_backup on-event=\"/system backup save name=team21_backup_daily\" interval=24h start-time=00:00:00
"

echo "
# Important Notes:
# 1. Router External IP: 172.18.13.21/16 (ether1)
# 2. Router Internal IP: 192.168.21.1/24 (ether2)
# 3. Web Server: 192.168.21.7
# 4. DNS Server: 192.168.21.5
# 5. Database Server: 192.168.21.12
# 6. DHCP Range: 192.168.21.100-192.168.21.200
# 7. Remember to change default password
# 8. Test connectivity after setup
# 9. Verify port forwarding
# 10. Monitor logs regularly
" 