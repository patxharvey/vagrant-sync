#!/bin/bash

# Define the configuration file path.
CONFIG_FILE="$HOME/bin/locations.cfg"

# Define and create the backup directory.
BACKUP_DIR="$HOME/bin/backups"
mkdir -p "$BACKUP_DIR"

# Define and create the checksum directory.
CHECKSUM_DIR="$HOME/bin/checksums"
mkdir -p "$CHECKSUM_DIR"

# Define and create the log directory.
LOG_DIR="$HOME/bin/logs"
mkdir -p "$LOG_DIR"

# Function to perform backup and check integrity from a parsed line
function perform_backup {
    local line="$1"
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)
    local basename=$(basename "$path")

    if [[ -z "$path" ]]; then
        echo "Invalid backup location specified."
        return
    fi

    local checksum_file="$CHECKSUM_DIR/$basename.checksum"
    local phantom_log="$LOG_DIR/$basename.phantom"

    # Calculate checksums before backup
    echo "Calculating checksums for $path"
    if [[ "$user_host" =~ "@" ]]; then
        ssh "$user_host" "export LC_ALL=C; find '$path' -type f -exec shasum -a 256 {} \;" > "$checksum_file"
    else
        find "$path" -type f -exec shasum -a 256 {} \; > "$checksum_file"
    fi

    # Perform backup
    echo "Backing up from $user_host:$path"
    rsync -avz -e "ssh -A" "$user_host:$path" "$BACKUP_DIR"
    echo "Backup completed for $user_host:$path"

    # Calculate checksums after backup and compare
    echo "Verifying integrity for $path"
    local new_checksum_file="$CHECKSUM_DIR/$basename.new.checksum"
    find "$BACKUP_DIR/$(basename "$path")" -type f -exec shasum -a 256 {} \; > "$new_checksum_file"

    # Compare checksums and log discrepancies
    if ! diff "$checksum_file" "$new_checksum_file" > "$phantom_log"; then
        echo "Discrepancies detected, marking affected files and logging."
        awk '{print $2}' "$phantom_log" | while read -r file; do
            if [[ -f "$file" ]]; then
                mv "$file" "$file.phantom"
                echo "File altered by phantom: $file" >> "$phantom_log"
            fi
        done
    fi
}

# Function to restore files to their original state based on good checksums
function perform_restore {
    local line_number=$1
    local line=$(sed -n "${line_number}p" $CONFIG_FILE)
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)

    echo "Restoring to $user_host:$path from $BACKUP_DIR/$(basename "$path")"
    rsync -av "$BACKUP_DIR/$(basename "$path")/" "$user_host:$path"
    echo "Restore completed for $user_host:$path"
}

# Function to revert altered files to their original state
function perform_integrity_restore {
    local line_number=$1
    local line=$(sed -n "${line_number}p" $CONFIG_FILE)
    local user_host=$(echo "$line" | cut -d':' -f1)
    local path=$(echo "$line" | cut -d':' -f2-)
    local basename=$(basename "$path")
    local phantom_log="$LOG_DIR/$basename.phantom"

    echo "Restoring integrity for $user_host:$path"
    while IFS= read -r log_line; do
        if [[ "$log_line" == *"File altered by phantom:"* ]]; then
            local altered_file=$(echo "$log_line" | awk -F': ' '{print $2}')
            local original_file="${altered_file%.phantom}"
            if [[ -f "$BACKUP_DIR/$original_file" ]]; then
                cp "$BACKUP_DIR/$original_file" "$user_host:$path/$original_file"
                echo "Restored $original_file to its original state."
            fi
        fi
    done < "$phantom_log"
}

# Handle script arguments for backup and restore operations.
case "$1" in
    -B)
        # Backup operations
        if [ -n "$2" ] && [ "$2" == "-L" ] && [ -n "$3" ]; then
            # Specific location
            perform_backup "$(sed -n "${3}p" $CONFIG_FILE)"
        else
            # All locations
            while IFS= read -r line; do
                perform_backup "$line"
            done < "$CONFIG_FILE"
        fi
        ;;
    -R)
        # Restore operations
        if [ -n "$2" ] && [ "$2" == "-L" ] && [ -n "$3" ]; then
            # Specific location
            perform_restore $3
        else
            # All locations
            local line_number=1
            while IFS= read -r line; do
                perform_restore $line_number
                ((line_number++))
            done < "$CONFIG_FILE"
        fi
        ;;
    -I)
        # Integrity restore operations
        if [ -n "$2" ] && [ "$2" == "-L" ] && [ -n "$3" ]; then
            # Specific location
            perform_integrity_restore $3
        else
            # All locations
            local line_number=1
            while IFS= read -r line; do
                perform_integrity_restore $line_number
                ((line_number++))
            done < "$CONFIG_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 -B [-L line_number] for backup operations, $0 -R [-L line_number] for restore operations, or $0 -I [-L line_number] for integrity restore operations."
        ;;
esac
