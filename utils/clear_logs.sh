#!/bin/bash

# Path to the logs directory
LOG_DIR="$HOME/bin/logs"

# Check if the directory exists
if [ -d "$LOG_DIR" ]; then
    # Remove all files and subdirectories in the logs directory
    rm -rf "$LOG_DIR"/*
    echo "Logs directory has been cleared."
else
    echo "Logs directory does not exist."
fi
