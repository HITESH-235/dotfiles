#!/bin/bash

# Path to the RefreshRate script
REFRESH_SCRIPT="$HOME/.config/hypr/scripts/RefreshRate.sh"

# Run once at startup
bash "$REFRESH_SCRIPT"

# Initial state
LAST_STATE=$(cat /sys/class/power_supply/AC0/online 2>/dev/null)

# Loop to monitor AC status changes
while true; do
    if [ -f /sys/class/power_supply/AC0/online ]; then
        CURRENT_STATE=$(cat /sys/class/power_supply/AC0/online)
        if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
            bash "$REFRESH_SCRIPT"
            LAST_STATE="$CURRENT_STATE"
        fi
    fi
    sleep 5
done
