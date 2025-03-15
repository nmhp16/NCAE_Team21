#!/bin/bash
# Exit on any error, treat unset variables as errors, and catch errors in pipelines.
set -euo pipefail
IFS=$'\n\t'

##########################################################################
# Script: create_users_one_real_others_dummy.sh
# Purpose: Securely create one REAL (team) user with sudo privileges and
#          multiple dummy (decoy) user accounts. The REAL user is forced
#          to change their password on first login and has a secure ~/.ssh
#          directory set up for future SSH key deployment. The dummy users
#          are created with a restricted shell (rbash) and then immediately
#          locked to prevent login.
#
# Usage: Run as root:
#    sudo ./create_users_one_real_others_dummy.sh
##########################################################################

# Define a secure file to log generated credentials.
CRED_FILE="/root/secure_user_credentials.txt"
echo "Initializing secure credentials file at ${CRED_FILE}..."
: > "${CRED_FILE}"       # Create or clear the file.
chmod 600 "${CRED_FILE}" # Restrict access to root only.

# Function: generate a very secure random password using hex encoding.
# This produces a 32-character (16-byte) password.
generate_password() {
    openssl rand -hex 16
}

# Define the REAL user (with sudo) and an array of dummy (decoy) users.
REAL_USER="team21_admin"
DUMMY_USERS=("admin" "webadmin" "dbadmin" "dnsadmin" "ftpadmin" "monitor" "backup" "root" "mysql" "apache" "www-data" "bind" "named" "vsftpd" "postgres" "redis" "mongodb" "elasticsearch" "kibana" "logstash" "prometheus" "grafana" "jenkins" "git" "svn" "docker" "kubernetes" "ansible" "puppet" "chef" "salt" "vagrant" "vagrant-user" "vagrant-admin" "vagrant-root" "vagrant-web" "vagrant-db" "vagrant-dns" "vagrant-ftp" "vagrant-monitor" "vagrant-backup")

echo "### Creating REAL user with sudo privileges: ${REAL_USER} ###"
if id "$REAL_USER" &>/dev/null; then
    echo "User $REAL_USER already exists. Skipping creation."
else
    # Create the real user with a home directory, bash shell, and add to the sudo group.
    useradd -m -s /bin/bash -G sudo "$REAL_USER"
    echo "User $REAL_USER created."
fi

# Generate a secure random password for the real user.
password=$(generate_password)
echo "Setting password for $REAL_USER..."
echo "$REAL_USER:$password" | chpasswd
# Force password change on first login.
chage -d 0 "$REAL_USER"
# Log the credentials securely.
echo "User: $REAL_USER, Temporary Password: $password" >> "${CRED_FILE}"

# Set up a secure .ssh directory for the real user.
SSH_DIR="/home/${REAL_USER}/.ssh"
mkdir -p "${SSH_DIR}"
chown "$REAL_USER":"$REAL_USER" "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Create authorized_keys file with proper permissions
touch "${SSH_DIR}/authorized_keys"
chown "$REAL_USER":"$REAL_USER" "${SSH_DIR}/authorized_keys"
chmod 600 "${SSH_DIR}/authorized_keys"

echo "Real user $REAL_USER processed successfully."

echo "### Creating DUMMY users with restricted shells ###"
for user in "${DUMMY_USERS[@]}"; do
    echo "Processing dummy user: $user"
    if id "$user" &>/dev/null; then
        echo "User $user already exists. Skipping creation."
    else
        # Create the dummy user with a restricted shell (rbash).
        useradd -m -s /bin/rbash "$user"
        echo "User $user created."
    fi

    # Generate a secure random password for the dummy user.
    dummy_password=$(generate_password)
    echo "Setting password for dummy user $user..."
    echo "$user:$dummy_password" | chpasswd
    # Immediately lock the account to disable interactive login.
    passwd -l "$user"
    # Log the dummy user credentials.
    echo "Dummy User: $user, Password: $dummy_password (Account Locked)" >> "${CRED_FILE}"

    # Create dummy files to simulate activity
    sudo -u "$user" mkdir -p "/home/$user/confidential"
    echo "FAKE_CREDENTIALS=team21_fake_$(openssl rand -hex 8)" | tee "/home/$user/confidential/credentials.txt" >/dev/null
    echo "FAKE_API_KEY=team21_fake_$(openssl rand -hex 16)" | tee "/home/$user/confidential/api_keys.txt" >/dev/null
    echo "FAKE_DB_PASSWORD=team21_fake_$(openssl rand -hex 12)" | tee "/home/$user/confidential/database.txt" >/dev/null

    echo "Dummy user $user processed successfully."
done

echo "### Setting Strict Directory Permissions ###"
# Set real user's home directory permissions to 700.
chmod -R 700 "/home/$REAL_USER"
# Set dummy users' home directories permissions to 750.
for user in "${DUMMY_USERS[@]}"; do
    chmod -R 750 "/home/$user"
done
echo "Directory permissions set."

echo "====================================================="
echo "🔐 REAL USER CREDENTIALS (Distribute privately ONLY):"
grep "User: $REAL_USER," "${CRED_FILE}"
echo "====================================================="
echo "[SECURITY]: Real user $REAL_USER has sudo privileges and is forced to change their password on first login."
echo "[SECURITY]: Dummy user accounts use a restricted shell and are locked."
echo "[SECURITY]: All passwords are randomly generated and must be changed on first login."
echo "[COMPLETE]: User setup complete!"
