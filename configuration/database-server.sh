#!/bin/bash
# Assign static IP to eth0
sudo ip addr add 192.168.21.7/24 dev eth0

# Set the default gateway
sudo ip route add default via 192.168.21.1

# Set DNS server
echo "nameserver 192.168.21.12" | sudo tee /etc/resolv.conf > /dev/null

# Activate the interface
sudo ip link set eth0 up

# Verify IP address
ip addr show eth0

# Test connectivity
ping 192.168.21.1
ping 192.168.21.12
