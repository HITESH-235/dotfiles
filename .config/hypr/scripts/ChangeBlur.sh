#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for changing blurs on the fly

notif="$HOME/.config/swaync/images"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [ "${STATE}" == "2" ]; then
	hyprctl keyword decoration:blur:size 2
	hyprctl keyword decoration:blur:passes 1
 	notify-send -e -u low -i "$notif/note.png" " Less Blur"
elif [ "${STATE}" == "1" ]; then
	hyprctl keyword decoration:blur:size 12
	hyprctl keyword decoration:blur:passes 4
	echo "windowrule = opacity 1.0 override 1.0 override, match:class .*" > "$HOME/.config/hypr/OpaqueOverride.conf"
	hyprctl reload
 	notify-send -e -u low -i "$notif/ja.png" " Full Blur (Opaque)"
else
	echo "" > "$HOME/.config/hypr/OpaqueOverride.conf"
	hyprctl reload
	sleep 0.5
	hyprctl keyword decoration:blur:size 5
	hyprctl keyword decoration:blur:passes 2
  	notify-send -e -u low -i "$notif/ja.png" " Normal Blur"
fi
