## 1. MikroTik Router (192.168.21.1)

### Initial Setup

```bash
# Login (default password: abc123)
ssh root@192.168.21.1

# Change password
/user set admin password="[TEAM_PASSWORD]"

# Firewall rules (allow scoring ports, block all else)
ip firewall filter add chain=input protocol=icmp action=accept
ip firewall filter add chain=input protocol=tcp dst-port=22,80,443,53 action=accept
ip firewall filter add chain=input action=drop

# Port forwarding (HTTP/HTTPS/DNS)
ip firewall nat add chain=dstnat dst-port=80 protocol=tcp to-address=192.168.21.7 to-port=80
ip firewall nat add chain=dstnat dst-port=443 protocol=tcp to-address=192.168.21.7 to-port=443
ip firewall nat add chain=dstnat dst-port=53 protocol=udp to-address=192.168.21.5 to-port=53
```

### Attack Response: Brute-Force SSH
```bash
# Block attacker IP (run on router)
ip firewall filter add chain=input src-address=172.18.13.666 action=drop
```

## 2. Web Server (192.168.21.7)

### Initial Setup

```bash
# Update & install Apache
apt update && apt upgrade -y
apt install apache2 -y

# Generate SSL certificate (if certbot is pre-installed)
certbot --no-verify-ssl --server ca.ncaecybergames.org/acme/acme/directory -d www.team21.com --apache

# Firewall rules
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -j DROP

# Create test page
echo "<h1>Team 21 - Secure</h1>" > /var/www/html/index.html
systemctl restart apache2
```

### Attack Response: Web Defacement ###
```bash
# Restore from backup
cp /var/www/html/backup/* /var/www/html/

# Block attacker IP
iptables -A INPUT -s 172.18.13.666 -j DROP
```

## 3. DNS Server (192.168.21.5)

### Initial Setup

```bash
# Install BIND9
apt update && apt install bind9 -y

# Configure zones (edit files)
nano /etc/bind/named.conf.local
# Add:
zone "team21.com" {
  type master;
  file "/etc/bind/zones/db.team21.com";
};

# Create forward zone file
echo -e "@\tIN\tA\t192.168.21.7\nwww\tIN\tA\t192.168.21.7" > /etc/bind/zones/db.team21.com

# Restart BIND
systemctl restart bind9
```

### Attack Response: DNS Spoofing
```bash
# Flush cache and restart
rndc flush
systemctl restart bind9

# Block attacker IP
iptables -A INPUT -s 172.18.13.666 -j DROP
```

## 4. Database Server (192.168.21.12)

### Initial Setup

```bash
# Create scoring user
sudo -u postgres psql
CREATE USER scorer WITH PASSWORD 'SecurePass123!';
GRANT CONNECT, SELECT, INSERT ON DATABASE scoring_db TO scorer;
\q

# Restrict access in pg_hba.conf
echo "host scoring_db scorer 192.168.21.0/24 md5" >> /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql
```

### Attack Response: SQL Injection
```bash
# Revoke attacker access
sudo -u postgres psql -c "REVOKE CONNECT ON DATABASE scoring_db FROM scorer;"
```

## 5. FTP/Shell Server (DHCP-Assigned IP)

### Initial Setup

The FTP/Shell server setup includes enabling SSH/SFTP and creating a user for secure file transfers.

```bash
# Enable SSH/SFTP
systemctl start ssh

# Create scoring user for SFTP access
useradd -m sftpuser
echo "sftpuser:Password123!" | chpasswd
```

### Attack Response: Brute-Force SSH
```bash
# Block attacker IP
iptables -A INPUT -s 172.18.13.666 -j DROP

# Check logs for failed login attempts
grep "Failed password" /var/log/auth.log
```

## 6. Kali Linux VM (Offensive Tool)

The Kali Linux VM is used for offensive security operations such as network reconnaissance, web path discovery, and traffic analysis. Below are the key tools and commands for effective use.

### Network Recon

Perform network scans to identify active hosts and open ports within the internal network.

```bash
# Scan internal network for active hosts and open ports
nmap -sV -p- 192.168.21.0/24

# Dirbuster for discovering web paths on the web server
gobuster dir -u http://192.168.21.7 -w /usr/share/wordlists/dirb/common.txt
```

### Traffic Analysis ###
```bash
# Capture HTTP and HTTPS traffic
tcpdump -i eth0 -w http.pcap 'tcp port 80 or port 443'

# Find flags within the captured traffic
strings http.pcap | grep -i "flag{"
```

## 7. Gravwell (172.18.16.212)
```bash
# List top blocked IPs
tag=firewall action=drop | stats count by src_ip | sort -count desc

# Analyze DNS query traffic
tag=dns query | stats count by query | sort -count desc
```