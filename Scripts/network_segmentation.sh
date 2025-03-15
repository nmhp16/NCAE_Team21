#!/bin/bash

# Network Segmentation Script for NCAE Cyber Games
# Implements VLANs and firewall rules for network isolation

# Configuration
INTERNAL_NET="192.168.21.0/24"
EXTERNAL_NET="172.18.0.0/16"

# VLAN IDs
VLAN_WEB=100
VLAN_DB=101
VLAN_DNS=102
VLAN_FTP=103
VLAN_ADMIN=104
VLAN_MONITOR=105

# VLAN IP Ranges
VLAN_WEB_IP="192.168.21.10-192.168.21.20"
VLAN_DB_IP="192.168.21.30-192.168.21.40"
VLAN_DNS_IP="192.168.21.50-192.168.21.60"
VLAN_FTP_IP="192.168.21.70-192.168.21.80"
VLAN_ADMIN_IP="192.168.21.90-192.168.21.100"
VLAN_MONITOR_IP="192.168.21.110-192.168.21.120"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

# Function to create VLAN
create_vlan() {
    local vlan_id=$1
    local vlan_name=$2
    
    log "Creating VLAN $vlan_id ($vlan_name)..."
    
    # Create VLAN interface
    vconfig add eth0 $vlan_id
    
    # Bring up VLAN interface
    ifconfig eth0.$vlan_id up
    
    # Add VLAN to bridge
    brctl addbr br$vlan_id
    brctl addif br$vlan_id eth0.$vlan_id
    
    success "VLAN $vlan_id created successfully"
}

# Function to configure VLAN IP range
configure_vlan_ip() {
    local vlan_id=$1
    local ip_range=$2
    
    log "Configuring IP range for VLAN $vlan_id..."
    
    # Configure DHCP server for VLAN
    cat > /etc/dhcp/dhcpd.conf.d/vlan$vlan_id.conf << EOF
subnet 192.168.21.0 netmask 255.255.255.0 {
    range $ip_range;
    option routers 192.168.21.1;
    option domain-name-servers 192.168.21.12;
}
EOF
    
    success "IP range configured for VLAN $vlan_id"
}

# Function to configure firewall rules
configure_firewall() {
    log "Configuring firewall rules..."
    
    # Default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Allow established connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    
    # Web VLAN rules
    iptables -A FORWARD -i br$VLAN_WEB -o br$VLAN_DB -p tcp --dport 3306 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_WEB -o br$VLAN_DNS -p udp --dport 53 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_WEB -o br$VLAN_FTP -p tcp --dport 21 -j ACCEPT
    
    # Database VLAN rules
    iptables -A FORWARD -i br$VLAN_DB -o br$VLAN_WEB -p tcp --sport 3306 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_DB -o br$VLAN_ADMIN -p tcp --dport 3306 -j ACCEPT
    
    # DNS VLAN rules
    iptables -A FORWARD -i br$VLAN_DNS -o br$VLAN_WEB -p udp --sport 53 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_DNS -o br$VLAN_ADMIN -p udp --dport 53 -j ACCEPT
    
    # FTP VLAN rules
    iptables -A FORWARD -i br$VLAN_FTP -o br$VLAN_WEB -p tcp --sport 21 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_FTP -o br$VLAN_ADMIN -p tcp --dport 21 -j ACCEPT
    
    # Admin VLAN rules
    iptables -A FORWARD -i br$VLAN_ADMIN -o br$VLAN_DB -p tcp --sport 3306 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_ADMIN -o br$VLAN_DNS -p udp --sport 53 -j ACCEPT
    iptables -A FORWARD -i br$VLAN_ADMIN -o br$VLAN_FTP -p tcp --sport 21 -j ACCEPT
    
    # Monitor VLAN rules
    iptables -A FORWARD -i br$VLAN_MONITOR -o br$VLAN_WEB -j ACCEPT
    iptables -A FORWARD -i br$VLAN_MONITOR -o br$VLAN_DB -j ACCEPT
    iptables -A FORWARD -i br$VLAN_MONITOR -o br$VLAN_DNS -j ACCEPT
    iptables -A FORWARD -i br$VLAN_MONITOR -o br$VLAN_FTP -j ACCEPT
    iptables -A FORWARD -i br$VLAN_MONITOR -o br$VLAN_ADMIN -j ACCEPT
    
    # Save firewall rules
    iptables-save > /etc/iptables.rules
    
    success "Firewall rules configured successfully"
}

# Function to configure monitoring
configure_monitoring() {
    log "Configuring network monitoring..."
    
    # Install monitoring tools
    apt-get update
    apt-get install -y tcpdump wireshark iftop nethogs
    
    # Configure tcpdump for each VLAN
    for vlan in $VLAN_WEB $VLAN_DB $VLAN_DNS $VLAN_FTP $VLAN_ADMIN $VLAN_MONITOR; do
        cat > /etc/systemd/system/tcpdump-vlan$vlan.service << EOF
[Unit]
Description=Tcpdump for VLAN $vlan
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/tcpdump -i br$vlan -w /var/log/tcpdump/vlan$vlan.pcap
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    done
    
    # Create log directory
    mkdir -p /var/log/tcpdump
    
    # Enable and start monitoring services
    systemctl daemon-reload
    for vlan in $VLAN_WEB $VLAN_DB $VLAN_DNS $VLAN_FTP $VLAN_ADMIN $VLAN_MONITOR; do
        systemctl enable tcpdump-vlan$vlan
        systemctl start tcpdump-vlan$vlan
    done
    
    success "Network monitoring configured successfully"
}

# Main script
log "Starting network segmentation setup..."

# Create VLANs
create_vlan $VLAN_WEB "web"
create_vlan $VLAN_DB "database"
create_vlan $VLAN_DNS "dns"
create_vlan $VLAN_FTP "ftp"
create_vlan $VLAN_ADMIN "admin"
create_vlan $VLAN_MONITOR "monitor"

# Configure VLAN IP ranges
configure_vlan_ip $VLAN_WEB "$VLAN_WEB_IP"
configure_vlan_ip $VLAN_DB "$VLAN_DB_IP"
configure_vlan_ip $VLAN_DNS "$VLAN_DNS_IP"
configure_vlan_ip $VLAN_FTP "$VLAN_FTP_IP"
configure_vlan_ip $VLAN_ADMIN "$VLAN_ADMIN_IP"
configure_vlan_ip $VLAN_MONITOR "$VLAN_MONITOR_IP"

# Configure firewall rules
configure_firewall

# Configure monitoring
configure_monitoring

success "Network segmentation setup completed successfully" 