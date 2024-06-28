#!/bin/bash

# Path to the backups directory
BACKUP_DIR="$HOME/bin/backups"

# Check if the directory exists
if [ -d "$BACKUP_DIR" ]; then
    # Remove all files and subdirectories in the backup directory
    rm -rf "$BACKUP_DIR"/*
    echo "Backups directory has been cleared."
else
    echo "Backup directory does not exist."
fi
