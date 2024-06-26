#!/bin/bash
CONFIG_FILE="locations.cfg"

# Function to check connection and create a file
check_connection_and_create_file() {
    local user_host=$(echo $1 | awk -F ':' '{print $1}')
    local path=$(echo $1 | awk -F ':' '{print $2}')
    echo "Attempting to connect to $user_host and create a file in $path..."

    # Attempt to connect using ssh and create a test file
    ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $user_host "touch $path/testfile_$(date +%Y%m%d%H%M%S).txt" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Successfully connected to $user_host and created file in $path (Status: Success)"
    else
        echo "Failed to connect or create file at $user_host:$path (Status: Failed)"
    fi
}

# Read configuration file and check connections
while IFS= read -r line || [ -n "$line" ]; do
    if [ ! -z "$line" ]; then
        check_connection_and_create_file "$line"
    fi
done < "$CONFIG_FILE"
