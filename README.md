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

## Configuration
locations.cfg: List of locations to backup or restore in the format [user]@[server host]:[path].
vagrant@localhost:/home/vagrant/media-backup-vagrant
pharvey@10.0.1.17:/Users/pharvey/dev/media-backup
Scripts
bkmedia.sh: Handles basic backup and restore operations.
bkmedia_integrity.sh: Adds functionality to detect and log files altered by the data integrity phantom.
bkmedia_phantom.sh: Incorporates all features including integrity restore.
Commands
Backup:

./bkmedia.sh -B                 # Backup all locations
./bkmedia.sh -B -L [line_number]  # Backup specific location by line number
Restore:

sh
Copy code
./bkmedia.sh -R                 # Restore all locations
./bkmedia.sh -R -L [line_number]  # Restore specific location by line number
Backup with Integrity Check:

sh
Copy code
./bkmedia_integrity.sh -B                 # Backup all locations with integrity check
./bkmedia_integrity.sh -B -L [line_number]  # Backup specific location with integrity check
Restore with Integrity Check:

sh
Copy code
./bkmedia_phantom.sh -R                 # Restore all locations
./bkmedia_phantom.sh -R -L [line_number]  # Restore specific location

Integrity Restore:

sh
Copy code
./bkmedia_phantom.sh -I                 # Restore integrity for all locations
./bkmedia_phantom.sh -I -L [line_number]  # Restore integrity for specific location
Utilities
clear_backups.sh: Clears the backups directory.
clear_checksums.sh: Clears the checksums directory.
clear_logs.sh: Clears the logs directory.
Utility Scripts Usage
Clear Backups:

sh
Copy code
./utils/clear_backups.sh
Clear Checksums:

sh
Copy code
./utils/clear_checksums.sh
Clear Logs:

sh
Copy code
./utils/clear_logs.sh
Challenges

Handling discrepancies caused by different path prefixes during checksum verification.
Ensuring remote and local backups work seamlessly.
Detecting and marking altered files accurately.
Future Improvements

Implementing a more robust mechanism for detecting data integrity issues.
Enhancing logging to include more detailed information.
Adding support for more complex backup and restore scenarios.# vagrant-sync
