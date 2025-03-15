# External LAN (172.18.0.0/16)
**Gravwell (172.18.16.212)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 172.18.16.212/16 gw4 172.18.13.21

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0  # Should show 172.18.16.212/16

# Test connectivity
ping 172.18.13.21  # Gateway (team router ether1)
ping 192.168.21.12  # DNS server (via router)
```
**External Kali (172.18.15.211-172.18.15.216)**
```bash
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 172.18.15.211/16 gw4 172.18.13.21
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12
sudo nmcli con up "static-eth0"
ip addr show eth0  # Verify 172.18.15.211/16
ping 172.18.13.21
ping 192.168.21.12
```
**Shell/FTP Server (172.18.14.21)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 172.18.14.21/16 gw4 172.18.13.21

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0  # Verify 172.18.14.21/16

# Test connectivity
ping 172.18.13.21
ping 192.168.21.12
```

**Team Router (Bridging External and Internal LANs)**
   - External Interface (ether1: 172.18.13.21)
   - Internal Interface (ether2: 192.168.21.1)
```bash
# Configure external interface (ether1)
sudo ip addr add 172.18.13.21/16 dev ether1
sudo ip link set ether1 up

# Configure internal interface (ether2)
sudo ip addr add 192.168.21.1/24 dev ether2
sudo ip link set ether2 up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
# To make permanent, edit /etc/sysctl.conf and add: net.ipv4.ip_forward=1

# Optional: Configure NAT for internal LAN to access external networks
sudo iptables -t nat -A POSTROUTING -o ether1 -j MASQUERADE

# Optional: Basic firewall rules
sudo iptables -A FORWARD -i ether2 -o ether1 -j ACCEPT
sudo iptables -A FORWARD -i ether1 -o ether2 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -j DROP

# Verify interfaces
ip addr show ether1  # Verify 172.18.13.21/16
ip addr show ether2  # Verify 192.168.21.1/24

# Test connectivity
ping 172.18.14.21  # Shell/FTP (external)
ping 192.168.21.5  # Web Server (internal)
```
# Internal LAN (192.168.21.0/24)
**Web Server (192.168.21.5)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.5/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Database (192.168.21.7)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.7/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**DNS (192.168.21.12)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.12/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Backup (192.168.21.15)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.15/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Internal Kali VM1 (192.168.21.41)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.41/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Internal Kali VM2 (192.168.21.42)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.42/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Internal Kali VM3 (192.168.21.43)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.43/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Internal Kali VM4 (192.168.21.44)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.44/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```
**Internal Kali VM5 (192.168.21.45)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.45/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```

**Internal Kali VM6 (192.168.21.46)**
```bash
# Add static connection
sudo nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.21.46/24 gw4 192.168.21.1

# Set DNS server
sudo nmcli con mod "static-eth0" ipv4.dns 192.168.21.12

# Activate the connection
sudo nmcli con up "static-eth0"

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
```