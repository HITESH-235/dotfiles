#!/bin/bash
if pgrep -f "waybar -c /home/hit235/.config/waybar/left_config" > /dev/null; then
    pkill -f "waybar -c /home/hit235/.config/waybar/left_config"
else
    waybar -c /home/hit235/.config/waybar/left_config -s /home/hit235/.config/waybar/left_style.css > /dev/null 2>&1 &
    disown
fi
