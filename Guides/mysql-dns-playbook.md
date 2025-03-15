#  Database (MySQL) and DNS Server Security Playbook

## Objective
Secure MySQL database and DNS server.

## MySQL Setup Instructions:

### **Step 1: Install MySQL Server**
`sudo apt update && sudo apt install mysql-server -y`


### **Step 2: Secure MySQL Immediately**
`sudo mysql_secure_installation`
Follow prompts to secure.

## DNS (BIND9) Setup Instructions:

### **Step 1: Install BIND9**
`sudo apt install bind9 -y`


### **Step 2: Secure DNS Configuration**
`sudo nano /etc/bind/named.conf.options`
Set:
`options { allow-query { localhost; 192.168.t.0/24; }; recursion no; };`


### **Step 3: Restart DNS**
`sudo systemctl restart bind9`


## Troubleshooting:
- MySQL access denied? Check passwords and privileges.
- DNS query failed? Verify DNS config carefully.

**END OF PLAYBOOK**

# DNS & MySQL Security Monitoring Guide

## DNS Server Monitoring

### 1. DNS Query Monitoring
```bash
# Monitor DNS queries in real-time
sudo tcpdump -i any -n udp port 53

# Check for DNS amplification attacks
sudo tcpdump -i any -n udp port 53 | grep -i "ANY"

# Monitor for zone transfer attempts
sudo tcpdump -i any -n tcp port 53

# Check for DNS cache poisoning attempts
sudo tail -f /var/log/named/security.log | grep -i "error\|warning"
```

### 2. DNS Server Protection
```bash
# Block DNS amplification attacks
sudo iptables -A INPUT -p udp --dport 53 -m string --string "ANY" --algo bm -j DROP

# Prevent zone transfers except from trusted servers
sudo sed -i 's/allow-transfer { none; };/allow-transfer { 192.168.21.0\/24; };/' /etc/bind/named.conf.options

# Enable DNSSEC
sudo named-checkconf /etc/bind/named.conf
sudo rndc secroots
```

### 3. DNS Log Analysis
```bash
# Check for failed queries
sudo tail -f /var/log/named/query.log | grep -i "error"

# Monitor for suspicious domains
sudo tail -f /var/log/named/query.log | grep -i "malware\|spam\|phish"

# Check for high query rates
sudo tail -f /var/log/named/query.log | awk '{print $1}' | sort | uniq -c | sort -nr
```

## MySQL Server Monitoring

### 1. Database Access Monitoring
```bash
# Monitor failed login attempts
sudo tail -f /var/log/mysql/error.log | grep "Access denied"

# Check for suspicious queries
sudo tail -f /var/log/mysql/query.log | grep -i "union\|load_file\|into outfile"

# Monitor for connection attempts
sudo tail -f /var/log/mysql/error.log | grep "Connect"

# Check for privilege changes
sudo tail -f /var/log/mysql/error.log | grep "GRANT\|REVOKE"
```

### 2. Database Security Checks
```bash
# Check for weak passwords
sudo mysql -e "SELECT user,host FROM mysql.user WHERE authentication_string='';"

# Monitor for new users
sudo mysql -e "SELECT user,host FROM mysql.user;"

# Check for suspicious databases
sudo mysql -e "SHOW DATABASES;"

# Monitor for privilege changes
sudo mysql -e "SELECT * FROM mysql.user WHERE Grant_priv='Y';"
```

### 3. Database Protection
```bash
# Block suspicious IPs
sudo iptables -A INPUT -p tcp --dport 3306 -s ATTACKER_IP -j DROP

# Prevent remote root login
sudo mysql -e "UPDATE mysql.user SET Host='localhost' WHERE User='root';"

# Disable file privileges
sudo mysql -e "UPDATE mysql.user SET File_priv='N' WHERE User!='root';"

# Flush privileges
sudo mysql -e "FLUSH PRIVILEGES;"
```

## Quick Response Actions

### 1. DNS Server Response
```bash
# Restart DNS service
sudo systemctl restart bind9

# Clear DNS cache
sudo rndc flush

# Check DNS status
sudo systemctl status bind9

# Verify DNS configuration
sudo named-checkconf /etc/bind/named.conf
```

### 2. MySQL Server Response
```bash
# Restart MySQL service
sudo systemctl restart mysql

# Check MySQL status
sudo systemctl status mysql

# Verify MySQL configuration
sudo mysql --check

# Backup affected databases
sudo mysqldump -u root -p DATABASE_NAME > backup.sql
```

## Evidence Collection

### 1. DNS Server Evidence
```bash
# Save DNS logs
sudo cp /var/log/named/query.log /var/log/incident/dns_queries.log
sudo cp /var/log/named/security.log /var/log/incident/dns_security.log

# Save DNS configuration
sudo cp /etc/bind/named.conf /var/log/incident/
sudo cp /etc/bind/named.conf.options /var/log/incident/

# Save zone files
sudo cp /etc/bind/zones/* /var/log/incident/zones/
```

### 2. MySQL Server Evidence
```bash
# Save MySQL logs
sudo cp /var/log/mysql/error.log /var/log/incident/mysql_error.log
sudo cp /var/log/mysql/query.log /var/log/incident/mysql_queries.log

# Save MySQL configuration
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /var/log/incident/

# Save user privileges
sudo mysql -e "SELECT * FROM mysql.user;" > /var/log/incident/mysql_users.txt
```

## Prevention Commands

### 1. DNS Server Hardening
```bash
# Disable recursion except for trusted networks
sudo sed -i 's/recursion yes;/recursion no;\nallow-recursion { 192.168.21.0\/24; };/' /etc/bind/named.conf.options

# Enable DNSSEC
sudo apt install dnssec-tools
sudo dnssec-keygen -a RSASHA256 -b 2048 -n ZONE example.com

# Set secure permissions
sudo chown -R bind:bind /etc/bind
sudo chmod 640 /etc/bind/named.conf*
```

### 2. MySQL Server Hardening
```bash
# Secure MySQL installation
sudo mysql_secure_installation

# Set secure file permissions
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 750 /var/lib/mysql

# Configure MySQL security options
sudo bash -c 'cat << EOF > /etc/mysql/mysql.conf.d/security.cnf
[mysqld]
skip-networking=0
bind-address=127.0.0.1
max_connections=100
max_connect_errors=5
EOF'
```

## Notes
- Monitor logs continuously
- Document all suspicious activities
- Save evidence for analysis
- Report incidents immediately
- Keep security tools updated
- Regular backups are essential

