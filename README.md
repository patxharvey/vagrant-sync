# Backup and Restore Service with Data Integrity Checks

## Overview

This project provides a backup and restore service for media files from multiple sources, with added functionality to detect, flag, and log files altered by a data integrity phantom.

## Features

Backup:
Backup all configured locations or a specific location.
Identify and log files altered by the data integrity phantom during the backup process.
Restore:
Restore all backups or a specific backup location.
Integrity Restore:
Revert altered files to their original state based on the last known good checksum.
Usage

Backup:

./bkmedia.sh -B                 # Backup all locations
./bkmedia.sh -B -L [line_number]  # Backup specific location by line number
Restore:

./bkmedia.sh -R                 # Restore all locations
./bkmedia.sh -R -L [line_number]  # Restore specific location by line number
Backup with Integrity Check:

./bkmedia_integrity.sh -B                 # Backup all locations with integrity check
./bkmedia_integrity.sh -B -L [line_number]  # Backup specific location with integrity check
Restore with Integrity Check:

./bkmedia_phantom.sh -R                 # Restore all locations
./bkmedia_phantom.sh -R -L [line_number]  # Restore specific location

Integrity Restore:

./bkmedia_phantom.sh -I                 # Restore integrity for all locations
./bkmedia_phantom.sh -I -L [line_number]  # Restore integrity for specific location


## Utility Scripts Usage

Clear Backups:
./utils/clear_backups.sh

Clear Checksums:
./utils/clear_checksums.sh

Clear Logs:
./utils/clear_logs.sh
