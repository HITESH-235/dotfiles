#!/bin/bash

# Define the show and hide signals for nwg-dock-hyprland
# SIGRTMIN+2 = show, SIGRTMIN+3 = hide
SHOW_SIGNAL=36
HIDE_SIGNAL=37

check_and_toggle() {
    # Get number of windows on current workspace
    WINDOWS=$(hyprctl activeworkspace -j | jq '.windows')
    
    if [ "$WINDOWS" -gt 0 ]; then
        # Hide dock if windows exist
        pkill -RTMIN+3 -f nwg-dock-hyprland
    else
        # Show dock if workspace is empty
        pkill -RTMIN+2 -f nwg-dock-hyprland
    fi
}

# Initial check
check_and_toggle

# Listen for workspace, open, and close events
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ $line == openwindow* ]] || [[ $line == closewindow* ]] || [[ $line == workspace* ]]; then
        check_and_toggle
    fi
done
