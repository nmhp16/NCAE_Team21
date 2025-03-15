#!/bin/bash
# Configure external interface (ether1)
sudo ip addr add 172.18.13.21/16 dev ether1
sudo ip link set ether1 up

# Configure internal interface (ether2)
sudo ip addr add 192.168.21.1/24 dev ether2
sudo ip link set ether2 up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Optional: Configure NAT for internal LAN to access external networks
sudo iptables -t nat -A POSTROUTING -o ether1 -j MASQUERADE

# Optional: Basic firewall rules
sudo iptables -A FORWARD -i ether2 -o ether1 -j ACCEPT
sudo iptables -A FORWARD -i ether1 -o ether2 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -j DROP

# Verify interfaces
ip addr show ether1
ip addr show ether2

# Test connectivity
ping 172.18.14.21  # Shell/FTP server
ping 192.168.21.5  # Web server
