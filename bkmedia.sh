#!/usr/bin/bash
CONFIG_FILE="locations.cfg"

#Functions
display_locations () {
	echo "Config Locations:"
	nl -w1 -s ': ' $CONFIG_FILE
}

display_locations
