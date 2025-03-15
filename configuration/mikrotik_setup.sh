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

# Configure IP addresses
/ip address add address=172.18.13.21/16 interface=ether1
/ip address add address=192.168.21.1/24 interface=ether2
"

# 4. DHCP Server Setup
echo "
# Setup DHCP server for internal network
/ip pool add name=dhcp_pool1 ranges=192.168.21.100-192.168.21.200
/ip dhcp-server network add address=192.168.21.0/24 gateway=192.168.21.1 dns-server=192.168.21.12
/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool1 disabled=no
"

# 5. NAT Configuration
echo "
# Setup NAT for internal network
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment=\"NAT for Internal Network\"
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

# Drop everything else
/ip firewall filter add chain=input action=drop comment=\"Drop all other input\"
"

# 7. DNS Settings
echo "
# Set DNS servers
/ip dns set servers=192.168.21.12,8.8.8.8
/ip dns set allow-remote-requests=yes
"

# 8. Bandwidth Management
echo "
# Simple queue for bandwidth management
/queue simple add name=internal-limit target=192.168.21.0/24 max-limit=100M/100M comment=\"Internal Network Limit\"
"

# 9. Logging Configuration
echo "
# Enable extended logging
/system logging add topics=info,!debug
/system logging add topics=error
/system logging add topics=warning
/system logging add topics=critical
"

# 10. Security Features
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

# 11. Backup Configuration
echo "
# Create backup
/system backup save name=team21_config
"

# 12. Additional Security Measures
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

# 13. Traffic Monitoring
echo "
# Enable traffic monitoring
/tool graphing interface add interface=ether1
/tool graphing interface add interface=ether2
/tool graphing resource add
"

# 14. System Scheduler
echo "
# Add daily backup scheduler
/system scheduler add name=daily_backup on-event=\"/system backup save name=team21_backup_daily\" interval=24h start-time=00:00:00

# Add daily script to remove old backups
/system scheduler add name=cleanup_backups on-event=\"/file remove [find name~\\\"team21_backup_daily\\\"]\" interval=24h start-time=01:00:00
"

echo "
# Important Notes:
# 1. Replace 'Team21SecurePass123!' with your actual secure password
# 2. Adjust bandwidth limits in queue simple based on your needs
# 3. Modify firewall rules based on specific requirements
# 4. Keep backup files secure
# 5. Monitor logs regularly
" 