# Web (Apache) and FTP Server Security Playbook

## Objective
Set up Web Server (Apache) with SSL certificate and secure FTP on the following servers:
- Web Server: 192.168.21.5
- FTP Server: 172.18.14.21

## Web Server SSL Instructions:

### **Step 1: Install Apache**
`sudo apt update && sudo apt install apache2 openssl -y && sudo systemctl enable apache2`

### **Step 2: Enable SSL module**
`sudo a2enmod ssl && sudo systemctl restart apache2`

### **Step 3: Generate CSR for CA**
Run:
`openssl req -newkey rsa:2048 -nodes -keyout team21.key -out team21.csr`
- **Upload `team21.csr` to CA server provided by competition.**
- **Download certificate (`team21.crt`).**

### **Step 4: Configure SSL in Apache**
`sudo nano /etc/apache2/sites-available/default-ssl.conf`
Edit lines to:
```
SSLCertificateFile /etc/ssl/certs/team21.crt
SSLCertificateKeyFile /etc/ssl/private/team21.key
```
Enable the site:
`sudo a2ensite default-ssl && sudo systemctl reload apache2`

## FTP Server Instructions:

### **Step 1: Install FTP Server (vsftpd)**
`sudo apt install vsftpd -y`

### **Step 2: Secure FTP Configuration**
Edit vsftpd config:
`sudo nano /etc/vsftpd.conf`
Add/Update these lines:
```
anonymous_enable=NO
write_enable=YES
local_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=172.18.14.21
```

### **Step 3: Restart FTP Server**
`sudo systemctl restart vsftpd`

## Troubleshooting:
- Apache SSL not working? Check paths to `.crt` and `.key` files.
- FTP Login issues? Double-check vsftpd config file.
- Can't connect to FTP? Verify firewall allows port 21 and passive ports (40000-50000).

# Web & FTP Attack Detection Guide

## Web Server Monitoring

### 1. Apache Security Monitoring
```bash
# Monitor for common web attacks
sudo tail -f /var/log/apache2/access.log | grep -i "sql\|injection\|xss\|upload\|shell"

# Check for directory traversal attempts
sudo tail -f /var/log/apache2/access.log | grep -i "\.\.\/\|\.\.\\"

# Monitor for file upload attempts
sudo tail -f /var/log/apache2/access.log | grep -i "\.php\|\.asp\|\.jsp\|\.exe"

# Check for suspicious user agents
sudo tail -f /var/log/apache2/access.log | grep -i "nmap\|nikto\|sqlmap"
```

### 2. Web Shell Detection
```bash
# Find suspicious PHP files
sudo find /var/www -type f -name "*.php" -mtime -1 -ls

# Check for encoded content
sudo find /var/www -type f -exec grep -l "base64_decode" {} \;

# Look for suspicious file permissions
sudo find /var/www -type f -perm -o+w -ls

# Check for hidden files
sudo find /var/www -type f -name ".*" -ls
```

### 3. Web Application Protection
```bash
# Block common attack patterns
sudo iptables -A INPUT -p tcp --dport 80 -m string --string "UNION SELECT" --algo bm -j DROP
sudo iptables -A INPUT -p tcp --dport 80 -m string --string "eval(" --algo bm -j DROP
sudo iptables -A INPUT -p tcp --dport 80 -m string --string "system(" --algo bm -j DROP

# Monitor for large POST requests
sudo tail -f /var/log/apache2/access.log | awk '$10 > 1000000'
```

## FTP Server Monitoring

### 1. FTP Security Checks
```bash
# Monitor failed login attempts
sudo tail -f /var/log/vsftpd.log | grep "FAIL LOGIN"

# Check for anonymous access attempts
sudo tail -f /var/log/vsftpd.log | grep "anonymous"

# Monitor for brute force attempts
sudo tail -f /var/log/vsftpd.log | grep "PASS: Client"

# Check for suspicious file transfers
sudo tail -f /var/log/vsftpd.log | grep -i "\.exe\|\.sh\|\.php"
```

### 2. FTP Directory Protection
```bash
# Check for unauthorized uploads
sudo find /var/ftp -type f -mtime -1 -ls

# Monitor for suspicious file permissions
sudo find /var/ftp -type f -perm -o+w -ls

# Check for hidden files
sudo find /var/ftp -type f -name ".*" -ls

# Look for executable files
sudo find /var/ftp -type f -executable -ls
```

### 3. FTP Service Protection
```bash
# Block FTP brute force attempts
sudo iptables -A INPUT -p tcp --dport 21 -m recent --name ftp_brute --rcheck --seconds 60 --hitcount 3 -j DROP

# Monitor for port scanning
sudo tcpdump -i any port 21 -n | grep -i "scan\|probe"

# Check for FTP bounce attacks
sudo tcpdump -i any port 21 -n | grep -i "PORT"
```

## Quick Response Actions

### 1. Web Server Response
```bash
# Block attacking IP
sudo iptables -A INPUT -s ATTACKER_IP -j DROP

# Restart web server
sudo systemctl restart apache2

# Clear web cache
sudo rm -rf /var/cache/apache2/*

# Check web server status
sudo systemctl status apache2
```

### 2. FTP Server Response
```bash
# Block FTP access from IP
sudo iptables -A INPUT -s ATTACKER_IP -p tcp --dport 21 -j DROP

# Restart FTP service
sudo systemctl restart vsftpd

# Check FTP status
sudo systemctl status vsftpd

# Review FTP logs
sudo tail -n 50 /var/log/vsftpd.log
```

## Evidence Collection

### 1. Web Server Evidence
```bash
# Save access logs
sudo cp /var/log/apache2/access.log /var/log/incident/web_access.log

# Save error logs
sudo cp /var/log/apache2/error.log /var/log/incident/web_error.log

# Save web directory state
sudo ls -la /var/www > /var/log/incident/web_files.txt

# Save web configuration
sudo cp /etc/apache2/apache2.conf /var/log/incident/
```

### 2. FTP Server Evidence
```bash
# Save FTP logs
sudo cp /var/log/vsftpd.log /var/log/incident/ftp.log

# Save FTP directory state
sudo ls -la /var/ftp > /var/log/incident/ftp_files.txt

# Save FTP configuration
sudo cp /etc/vsftpd.conf /var/log/incident/
```

## Prevention Commands

### 1. Web Server Hardening
```bash
# Disable directory listing
sudo sed -i 's/Options Indexes/Options -Indexes/' /etc/apache2/apache2.conf

# Set secure file permissions
sudo find /var/www -type f -exec chmod 644 {} \;
sudo find /var/www -type d -exec chmod 755 {} \;

# Enable security headers
sudo bash -c 'cat << EOF > /etc/apache2/conf-available/security-headers.conf
Header set X-Content-Type-Options "nosniff"
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"
Header set Strict-Transport-Security "max-age=31536000; includeSubDomains"
EOF'
```

### 2. FTP Server Hardening
```bash
# Disable anonymous access
sudo sed -i 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd.conf

# Set secure file permissions
sudo find /var/ftp -type f -exec chmod 644 {} \;
sudo find /var/ftp -type d -exec chmod 755 {} \;

# Enable chroot
sudo sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd.conf
```

## Notes
- Monitor logs continuously
- Document all suspicious activities
- Save evidence for analysis
- Report incidents immediately
- Keep security tools updated

**END OF PLAYBOOK**


