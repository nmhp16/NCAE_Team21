#!/bin/bash
# Exit on error, treat unset variables as errors, and catch errors in pipelines.
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# Script: create_users_secure.sh
# Purpose: Securely create real (team) and decoy (fake) user accounts with
#          very secure, randomly generated hex passwords.
#
#   - REAL USERS: Added to sudo, forced to change their password on first login,
#     and provided with a secure ~/.ssh directory for later key deployment.
#
#   - FAKE USERS: Created with a restricted shell (rbash) and immediately locked.
#
#   - Strict directory permissions are applied:
#         * REAL users: home directories set to 700.
#         * FAKE users: home directories set to 750.
#
# Usage: Run as root:
#    sudo ./create_users_secure.sh
##########################################################################

# Define a secure file to log generated credentials.
CRED_FILE="/root/secure_user_credentials.txt"
echo "Initializing secure credentials file at ${CRED_FILE}..."
: > "${CRED_FILE}"       # Create or clear the file.
chmod 600 "${CRED_FILE}" # Restrict access to root only.

# Function: generate a very secure random password using hex encoding.
# This produces a 64-character (32-byte) password.
generate_password() {
    openssl rand -hex 32
}

# Define arrays for real (team) users and fake (decoy) users
REAL_USERS=("team21_admin" "team21_web" "team21_db" "team21_dns" "team21_ftp" "team21_monitor" "team21_backup")
FAKE_USERS=("admin" "webadmin" "dbadmin" "dnsadmin" "ftpadmin" "monitor" "backup" "root" "mysql" "apache" "www-data" "bind" "named" "vsftpd" "postgres" "redis" "mongodb" "elasticsearch" "kibana" "logstash" "prometheus" "grafana" "jenkins" "git" "svn" "docker" "kubernetes" "ansible" "puppet" "chef" "salt" "vagrant" "vagrant-user" "vagrant-admin" "vagrant-root" "vagrant-web" "vagrant-db" "vagrant-dns" "vagrant-ftp" "vagrant-monitor" "vagrant-backup")

echo "### Creating REAL users with sudo privileges ###"
for user in "${REAL_USERS[@]}"; do
    echo "Processing real user: $user"
    if id "$user" &>/dev/null; then
        echo "User $user already exists. Skipping creation."
    else
        # Create the user with a home directory, bash shell, and add to the sudo group.
        useradd -m -s /bin/bash -G sudo "$user"
        echo "User $user created."
    fi

    # Generate a very secure random password.
    password=$(generate_password)
    echo "Setting password for $user..."
    echo "$user:$password" | chpasswd
    # Force password change on first login.
    chage -d 0 "$user"
    # Log the credentials securely.
    echo "User: $user, Temporary Password: $password" >> "${CRED_FILE}"

    # Set up a secure .ssh directory for future SSH key deployment.
    SSH_DIR="/home/${user}/.ssh"
    mkdir -p "${SSH_DIR}"
    chown "$user":"$user" "${SSH_DIR}"
    chmod 700 "${SSH_DIR}"

    # Create authorized_keys file with proper permissions
    touch "${SSH_DIR}/authorized_keys"
    chown "$user":"$user" "${SSH_DIR}/authorized_keys"
    chmod 600 "${SSH_DIR}/authorized_keys"

    echo "Real user $user processed successfully."
done

echo "### Creating FAKE users with restricted shells ###"
for user in "${FAKE_USERS[@]}"; do
    echo "Processing fake user: $user"
    if id "$user" &>/dev/null; then
        echo "User $user already exists. Skipping creation."
    else
        # Create the fake user with a restricted shell (rbash).
        useradd -m -s /bin/rbash "$user"
        echo "User $user created."
    fi

    # Generate a very secure random password for the fake user.
    fake_password=$(generate_password)
    echo "Setting password for fake user $user..."
    echo "$user:$fake_password" | chpasswd
    # Immediately lock the account to disable interactive login.
    passwd -l "$user"
    # Log the fake user credentials.
    echo "Fake User: $user, Password: $fake_password (Account Locked)" >> "${CRED_FILE}"

    # Create dummy files to simulate activity
    sudo -u "$user" mkdir -p "/home/$user/confidential"
    echo "FAKE_CREDENTIALS=team21_fake_$(openssl rand -hex 8)" | tee "/home/$user/confidential/credentials.txt" >/dev/null
    echo "FAKE_API_KEY=team21_fake_$(openssl rand -hex 16)" | tee "/home/$user/confidential/api_keys.txt" >/dev/null
    echo "FAKE_DB_PASSWORD=team21_fake_$(openssl rand -hex 12)" | tee "/home/$user/confidential/database.txt" >/dev/null

    echo "Fake user $user processed successfully."
done

echo "### Setting Strict Directory Permissions ###"
# Set fake users' home directories to 750 and real users' to 700.
for user in "${FAKE_USERS[@]}"; do
    chmod -R 750 "/home/$user"
done
for user in "${REAL_USERS[@]}"; do
    chmod -R 700 "/home/$user"
done
echo "Directory permissions set."

echo "====================================================="
echo "🔐 REAL USER CREDENTIALS (Distribute privately ONLY):"
for user in "${REAL_USERS[@]}"; do
    grep "User: $user," "${CRED_FILE}"
done
echo "====================================================="
echo "[SECURITY]: Real user accounts have sudo privileges and are forced to change their passwords on first login."
echo "[SECURITY]: Fake user accounts use a restricted shell and are locked."
echo "[SECURITY]: All passwords are randomly generated and must be changed on first login."
echo "[COMPLETE]: User setup complete!"
