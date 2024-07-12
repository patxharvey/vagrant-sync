#!/bin/bash

# Path to the checksums directory
CHECKSUM_DIR="$HOME/bin/checksums"

# Check if the directory exists
if [ -d "$CHECKSUM_DIR" ]; then
    # Remove all files and subdirectories in the checksums directory
    rm -rf "$CHECKSUM_DIR"/*
    echo "Checksums directory has been cleared."
else
    echo "Checksums directory does not exist."
fi
