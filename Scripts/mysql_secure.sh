#!/bin/bash

# MySQL Secure Installation Script
# For NCAE Cyber Games Competition
# Run this script ONLY on the dedicated MySQL Database Server (192.168.21.7).

echo "[START] Securing MySQL Database Server."

# Step 1: Update system packages and install MySQL Server
echo "[INFO] Installing MySQL server..."
sudo apt update
sudo apt install mysql-server -y

# Ensure MySQL is started and enabled to start on boot
sudo systemctl enable mysql
sudo systemctl start mysql

# Step 2: Configure MySQL to listen only on internal network
echo "[INFO] Configuring MySQL to listen on internal network..."
sudo sed -i 's/bind-address.*=.*/bind-address = 192.168.21.7/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Step 3: Configure firewall for MySQL
echo "[INFO] Configuring firewall for MySQL..."
sudo ufw allow from 192.168.21.0/24 to any port 3306

# Step 4: Run MySQL Secure Installation (Interactive setup)
echo "[ACTION REQUIRED] Starting mysql_secure_installation wizard."

sudo mysql_secure_installation

# When prompted by mysql_secure_installation, follow these best practices:
# - Set a STRONG root password.
# - Remove anonymous users (choose YES).
# - Disallow root login remotely (choose YES).
# - Remove test database and access (choose YES).
# - Reload privilege tables now (choose YES).

# Step 5: Create a limited-privilege user for web application
echo "[INFO] Creating limited-privilege user for web application..."
sudo mysql -e "CREATE USER 'webapp'@'192.168.21.5' IDENTIFIED BY 'CHANGE_THIS_PASSWORD';"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON webapp.* TO 'webapp'@'192.168.21.5';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "[COMPLETE] MySQL installed and secured successfully."
echo "[INFO] MySQL server is accessible at 192.168.21.7"

# Check if MySQL service is running properly
sudo systemctl status mysql | grep Active

