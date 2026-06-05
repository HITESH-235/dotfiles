#!/usr/bin/env bash
echo "$(date): Script run by $(whoami)" >> /tmp/toggle_playerctl.log
FILE="/home/hit235/.config/waybar/user-overrides.css"
RULE="#custom-playerctl { font-size: 0px; padding: 0px; margin: 0px; min-width: 0px; opacity: 0; }"

if grep -q "custom-playerctl" "$FILE"; then
    # Remove the rule
    sed -i '/custom-playerctl/d' "$FILE"
else
    # Append the rule
    echo "$RULE" >> "$FILE"
fi

# Reload waybar CSS
pkill -SIGUSR2 waybar

