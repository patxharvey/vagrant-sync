#!/bin/bash

# Define the configuration file path.
CONFIG_FILE="$HOME/bin/locations.cfg"

# Define and create the backup directory.
BACKUP_DIR="$HOME/bin/backups"
mkdir -p "$BACKUP_DIR"

# Function to perform backup from a parsed line
function perform_backup {
    local line="$1"
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)

    if [[ -z "$path" ]]; then
        echo "Invalid backup location specified."
        return
    fi

    # Check explicitly for localhost to differentiate between local and remote backups.
    if [[ "$user_host" == "vagrant@localhost" ]]; then
        # Perform local backup using rsync.
        echo "Backing up from local location: $path"
        rsync -av "$path" "$BACKUP_DIR"
    else
        # Perform remote backup using rsync over SSH.
        echo "Backing up from remote location: $user_host:$path"
        rsync -avz -e "ssh -A" "$user_host:$path" "$BACKUP_DIR"
    fi
    echo "Backup completed for $user_host:$path"
}

# Function to backup all entries
function backup_all {
    echo "Initiating backup for all locations..."
    local count=0
    while IFS= read -r line || [[ -n "$line" ]]; do  # Ensure to handle the last line without a newline
        if [[ -z "$line" ]]; then
            continue # Skip empty lines
        fi
        perform_backup "$line"
        ((count++))
    done < "$CONFIG_FILE"
    echo "Processed $count locations."
}

# Function to backup a specific line number
function backup_specific {
    local line_number=$1
    local line=$(sed -n "${line_number}p" $CONFIG_FILE)
    if [[ -z "$line" ]]; then
        echo "No valid entry found at line $line_number"
        return
    fi
    perform_backup "$line"
}

# Function to perform restore from a parsed line
function perform_restore {
    local line_number=$1
    local line=$(sed -n "${line_number}p" $CONFIG_FILE)
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)

    echo "Restoring to $user_host:$path from $BACKUP_DIR/$(basename "$path")"
    rsync -av "$BACKUP_DIR/$(basename "$path")/" "$user_host:$path"
    echo "Restore completed for $user_host:$path"
}

# Function to restore all entries
function restore_all {
    echo "Initiating restore for all locations..."
    local count=0
    local line_number=1
    while IFS= read -r line || [[ -n "$line" ]]; do  # Ensure to handle the last line without a newline
        if [[ -z "$line" ]]; then
            continue # Skip empty lines
        fi
        perform_restore $line_number
        ((count++))
        ((line_number++))
    done < "$CONFIG_FILE"
    echo "Processed $count locations."
}

# Function to restore a specific line number
function restore_specific {
    local line_number=$1
    perform_restore $line_number
}

# Handle script arguments for backup and restore operations.
case "$1" in
    -B)
        if [ -n "$2" ] && [ "$2" == "-L" ] && [ -n "$3" ]; then
            # Call backup function with the specific line number.
            backup_specific $3
        else
            # No -L flag, backup all locations.
            backup_all
        fi
        ;;
    -R)
        if [ -n "$2" ] && [ "$2" == "-L" ] && [ -n "$3" ]; then
            # Call restore function with the specific line number.
            restore_specific $3
        else
            # No -L flag, restore all locations.
            restore_all
        fi
        ;;
    *)
        # Display general usage when no valid arguments are provided.
        echo "Usage: $0 -B or -R [-L line_number] for backup or restore operations."
        ;;
esac
