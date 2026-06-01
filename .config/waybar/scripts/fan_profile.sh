#!/bin/bash

# Function to get current profile and return JSON for Waybar
get_profile() {
    local profile=$(asusctl profile get | grep "Active profile:" | awk '{print $NF}')
    
    case "$profile" in
        "Quiet")
            echo '{"text": "󰔄", "alt": "quiet", "class": "quiet", "tooltip": "Current: Quiet (Cool & Silent)"}'
            ;;
        "Balanced")
            echo '{"text": "󰈐", "alt": "balanced", "class": "balanced", "tooltip": "Current: Balanced"}'
            ;;
        "Performance")
            echo '{"text": "󱗗", "alt": "performance", "class": "performance", "tooltip": "Current: Performance (High Power)"}'
            ;;
        *)
            echo '{"text": "󰈐?", "alt": "unknown", "class": "unknown", "tooltip": "Current: Unknown"}'
            ;;
    esac
}

# Function to cycle profile
cycle_profile() {
    asusctl profile next > /dev/null
    pkill -RTMIN+10 waybar
}

if [[ "$1" == "--cycle" ]]; then
    cycle_profile
else
    get_profile
fi
