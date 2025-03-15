#!/bin/bash

# Backup System Script for NCAE Cyber Games
# Handles system backups, verification, and recovery

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d)
BACKUP_NAME="backup_${DATE}"
LOG_FILE="/var/log/backup.log"
VERIFY_FILE="/var/log/backup_verify.log"
RETENTION_DAYS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}" | tee -a "$LOG_FILE"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to perform full backup
full_backup() {
    log "Starting full system backup..."
    
    # Create backup directory
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    mkdir -p "$BACKUP_PATH"
    
    # Backup system configurations
    log "Backing up system configurations..."
    tar -czf "$BACKUP_PATH/etc.tar.gz" /etc/
    
    # Backup user data
    log "Backing up user data..."
    tar -czf "$BACKUP_PATH/home.tar.gz" /home/
    
    # Backup web content
    log "Backing up web content..."
    tar -czf "$BACKUP_PATH/var_www.tar.gz" /var/www/
    
    # Backup database
    log "Backing up MySQL database..."
    mysqldump -u root -p'team21_secure_db_pass' --all-databases > "$BACKUP_PATH/mysql_backup.sql"
    
    # Backup SSL certificates
    log "Backing up SSL certificates..."
    tar -czf "$BACKUP_PATH/ssl.tar.gz" /etc/ssl/
    
    # Backup SSH keys
    log "Backing up SSH keys..."
    tar -czf "$BACKUP_PATH/ssh.tar.gz" /etc/ssh/
    
    # Create backup manifest
    log "Creating backup manifest..."
    find "$BACKUP_PATH" -type f -exec sha256sum {} \; > "$BACKUP_PATH/manifest.txt"
    
    success "Full backup completed successfully"
}

# Function to perform incremental backup
incremental_backup() {
    log "Starting incremental backup..."
    
    # Get latest backup directory
    LATEST_BACKUP=$(ls -td "$BACKUP_DIR"/backup_* 2>/dev/null | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        error "No previous backup found. Performing full backup instead."
        full_backup
        return
    fi
    
    # Create new backup directory
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    mkdir -p "$BACKUP_PATH"
    
    # Perform incremental backup using rsync
    log "Performing incremental backup..."
    rsync -av --link-dest="$LATEST_BACKUP" /etc/ "$BACKUP_PATH/etc/"
    rsync -av --link-dest="$LATEST_BACKUP" /home/ "$BACKUP_PATH/home/"
    rsync -av --link-dest="$LATEST_BACKUP" /var/www/ "$BACKUP_PATH/var_www/"
    
    # Backup database (always full backup)
    log "Backing up MySQL database..."
    mysqldump -u root -p'team21_secure_db_pass' --all-databases > "$BACKUP_PATH/mysql_backup.sql"
    
    # Create backup manifest
    log "Creating backup manifest..."
    find "$BACKUP_PATH" -type f -exec sha256sum {} \; > "$BACKUP_PATH/manifest.txt"
    
    success "Incremental backup completed successfully"
}

# Function to verify backup
verify_backup() {
    log "Verifying backup integrity..."
    
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        error "Backup directory not found: $BACKUP_PATH"
        return 1
    fi
    
    # Verify manifest
    log "Verifying backup manifest..."
    cd "$BACKUP_PATH" && sha256sum -c manifest.txt > "$VERIFY_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        success "Backup verification completed successfully"
    else
        error "Backup verification failed. Check $VERIFY_FILE for details."
    fi
}

# Function to clean old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    # Remove backups older than retention period
    find "$BACKUP_DIR" -type d -name "backup_*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;
    
    success "Cleanup completed successfully"
}

# Function to restore from backup
restore_backup() {
    BACKUP_PATH="$BACKUP_DIR/$1"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        error "Backup directory not found: $BACKUP_PATH"
        return 1
    fi
    
    log "Starting system restore from $1..."
    
    # Verify backup before restore
    verify_backup
    
    # Restore system configurations
    log "Restoring system configurations..."
    tar -xzf "$BACKUP_PATH/etc.tar.gz" -C /
    
    # Restore user data
    log "Restoring user data..."
    tar -xzf "$BACKUP_PATH/home.tar.gz" -C /
    
    # Restore web content
    log "Restoring web content..."
    tar -xzf "$BACKUP_PATH/var_www.tar.gz" -C /
    
    # Restore database
    log "Restoring MySQL database..."
    mysql -u root -p'team21_secure_db_pass' < "$BACKUP_PATH/mysql_backup.sql"
    
    # Restore SSL certificates
    log "Restoring SSL certificates..."
    tar -xzf "$BACKUP_PATH/ssl.tar.gz" -C /
    
    # Restore SSH keys
    log "Restoring SSH keys..."
    tar -xzf "$BACKUP_PATH/ssh.tar.gz" -C /
    
    success "System restore completed successfully"
}

# Main script
case "$1" in
    "full")
        full_backup
        verify_backup
        ;;
    "incremental")
        incremental_backup
        verify_backup
        ;;
    "verify")
        verify_backup
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    "restore")
        if [ -z "$2" ]; then
            error "Please specify backup date (YYYYMMDD)"
            exit 1
        fi
        restore_backup "$2"
        ;;
    *)
        echo "Usage: $0 {full|incremental|verify|cleanup|restore [date]}"
        exit 1
        ;;
esac

# Final cleanup
cleanup_old_backups

log "Backup process completed" 