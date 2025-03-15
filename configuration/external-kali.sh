#!/bin/bash
# Verify 172.18.15.211-216/16

# Assign static IP to eth0
sudo ip addr add 172.18.15.211/16 dev eth0

# Set the default gateway
sudo ip route add default via 172.18.13.21

# Set DNS server
echo "nameserver 192.168.21.12" | sudo tee /etc/resolv.conf > /dev/null

# Activate the interface
sudo ip link set eth0 up

# Verify IP address
ip addr show eth0

# Test connectivity
ping 172.18.13.21
ping 192.168.21.12
