#!/bin/bash

# Cycle the profile
asusctl profile next > /dev/null

# Get the new profile name
profile=$(asusctl profile get | grep "Active profile:" | awk '{print $NF}')

# Send a notification (OSD)
# We use a custom icon name if possible, or just the text
notify-send -e -u low -i "fan" "Cooling Mode" "Set to: $profile"

# Refresh waybar
pkill -RTMIN+10 waybar
