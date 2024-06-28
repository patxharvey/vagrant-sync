#!/bin/bash

# Configuration file path
CONFIG_FILE="locations.cfg"
BACKUP_DIR="/home/vagrant/bin/backups"  # Ensure this directory is correct and exists

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Simple backup function
simple_backup() {
    echo "Starting backup process..."
    # Read each line from the configuration file
    while IFS= read -r line; do
        if [[ "$line" =~ "localhost" ]]; then
            # Local backup: remove 'localhost:' prefix and use direct path
            src="${line#*:}"
            echo "Backing up from local location: $src"
            rsync -av "/$src" "$BACKUP_DIR"
        else
            # Remote backup: ensure the full user@host:path format is maintained
            src="${line}"
            echo "Backing up from remote location: $src"
            # Use SSH with agent forwarding for remote backups
            rsync -avz -e "ssh -A" "$src" "$BACKUP_DIR"
        fi
    done < "$CONFIG_FILE"
    echo "Backup process completed."
}

# Execute the backup function
simple_backup
