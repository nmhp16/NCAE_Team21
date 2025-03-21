#!/bin/bash

# Apache Web Server SSL Setup Script
# For NCAE Cyber Games Competition
# Run on Web Server (192.168.21.5) ONLY

echo "[START] Apache Web Server SSL Setup."

# Step 1: Install Apache and OpenSSL
echo "[INFO] Updating packages and installing Apache and OpenSSL..."
sudo apt update
sudo apt install apache2 openssl -y

# Enable Apache service to start at boot
sudo systemctl enable apache2

# Step 2: Enable Apache SSL Module
echo "[INFO] Enabling Apache SSL module..."
sudo a2enmod ssl
sudo systemctl restart apache2

# Step 3: Generate CSR and Private Key for SSL certificate
echo "[INFO] Generating SSL private key and CSR..."
openssl req -newkey rsa:2048 -nodes -keyout team21.key -out team21.csr

echo "[INFO] CSR generated: team21.csr"
echo "[ACTION REQUIRED] Upload 'team21.csr' to NCAE CA server to obtain your SSL certificate."

# Step 4: After receiving SSL Certificate from CA Server (Manual Step)
# Place your received certificate (team21.crt) and the generated key (team21.key) securely on server.
# Update Apache SSL configuration:
#
# sudo nano /etc/apache2/sites-available/default-ssl.conf
# 
# Find and update:
# SSLCertificateFile /etc/ssl/certs/team21.crt
# SSLCertificateKeyFile /etc/ssl/private/team21.key
#
# Enable SSL site and restart Apache:
# sudo a2ensite default-ssl
# sudo systemctl reload apache2

echo "[INFO] Apache SSL initial setup completed. Complete Step 4 manually once SSL cert is received."

