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

**END OF PLAYBOOK**


