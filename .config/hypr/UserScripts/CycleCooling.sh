#!/bin/bash

# Get the current profile from power-profiles-daemon
current=$(powerprofilesctl get)

# Cycle the profile
if [ "$current" = "power-saver" ]; then
    next="balanced"
elif [ "$current" = "balanced" ]; then
    next="performance"
else
    next="power-saver"
fi

# Set the new profile
powerprofilesctl set "$next"

# Get the new active asusctl profile for notification
profile=$(asusctl profile get | grep "Active profile:" | awk '{print $NF}')

# Select appropriate system icon based on the profile
if [ "$profile" = "Performance" ]; then
    icon="power-profile-performance-symbolic"
elif [ "$profile" = "Quiet" ]; then
    icon="power-profile-power-saver-symbolic"
else
    icon="power-profile-balanced-symbolic"
fi

# Send a notification (OSD)
notify-send -e -u low -i "$icon" "Cooling Mode" "Set to: $profile"

# Refresh waybar
pkill -RTMIN+10 waybar
