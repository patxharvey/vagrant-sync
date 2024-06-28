#!/bin/bash

# Define the configuration file path.
CONFIG_FILE="$HOME/bin/locations.cfg"

# Define and create the backup directory.
BACKUP_DIR="$HOME/bin/backups"
mkdir -p "$BACKUP_DIR"

# Define and create the checksum directory.
checksum_dir="$HOME/bin/checksums"
mkdir -p "$checksum_dir"

# Define and create the log directory.
log_dir="$HOME/bin/logs"
mkdir -p "$log_dir"

# Function to perform backup from a parsed line
function perform_backup {
    local line="$1"
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)
    local checksum_file="$checksum_dir/$(basename "$path").checksum"
    local log_file="$log_dir/$(basename "$path").log"

    if [[ -z "$path" ]]; then
        echo "Invalid backup location specified."
        return
    fi

    # Calculate checksums and check for changes
    echo "Calculating checksums for location $user_host:$path"
    local current_checksums=$(mktemp)
    if [[ "$user_host" =~ "@" ]]; then
        # Remote backup
        ssh "$user_host" "find '$path' -type f -exec shasum -a 256 {} +" > "$current_checksums"
    else
        # Local backup
        find "$path" -type f -exec shasum -a 256 {} + > "$current_checksums"
    fi

    # Compare with previous checksums and detect changes
    if [ -f "$checksum_file" ]; then
        echo "Checking for changes..."
        while read -r line; do
            local filename=$(echo "$line" | awk '{print $2}')
            local new_checksum=$(echo "$line" | awk '{print $1}')
            local old_checksum=$(grep "$filename" "$checksum_file" | awk '{print $1}')
            if [ "$new_checksum" != "$old_checksum" ]; then
                echo "Change detected in $filename: $old_checksum -> $new_checksum" >> "$log_file"
                mv "$filename" "$filename.phantom"
            fi
        done < "$current_checksums"
    fi

    # Update the checksum file
    mv "$current_checksums" "$checksum_file"

    # Perform backup
    echo "Backing up from $user_host:$path"
    rsync -avz -e "ssh -A" "$user_host:$path" "$BACKUP_DIR"
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

# Handle script arguments for backup operations.
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
    *)
        # Display general usage when no valid arguments are provided.
        echo "Usage: $0 -B [-L line_number] for backup operations."
        ;;
esac
