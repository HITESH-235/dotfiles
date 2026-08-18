#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# This is for custom version of waybar idle_inhibitor which activates / deactivates hypridle instead

PROCESS="hypridle"

if [[ "$1" == "status" ]]; then
    sleep 1
    if pgrep -x "$PROCESS" >/dev/null; then
        echo '{"text": "RUNNING", "class": "active", "tooltip": "idle_inhibitor NOT ACTIVE\nLeft Click: Activate\nRight Click: Lock Screen"}'
    else
        echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "idle_inhibitor is ACTIVE\nLeft Click: Deactivate\nRight Click: Lock Screen"}'
    fi
elif [[ "$1" == "toggle" ]]; then
    if pgrep -x "$PROCESS" >/dev/null; then
        systemctl --user stop hypridle.service hypridle-battery.service || pkill "$PROCESS"
    else
        AC_STATUS=$(cat /sys/class/power_supply/AC0/online 2>/dev/null)
        if [ "$AC_STATUS" -eq 1 ]; then
            systemctl --user start hypridle.service || { hypridle >/dev/null 2>&1 & disown; }
        else
            systemctl --user start hypridle-battery.service || { hypridle -c "$HOME/.config/hypr/hypridle_battery.conf" >/dev/null 2>&1 & disown; }
        fi
    fi
else
    echo "Usage: $0 {status|toggle}"
    exit 1
fi
