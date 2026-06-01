#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for keyboard backlights (if supported) using brightnessctl

iDIR="$HOME/.config/swaync/icons"

# Get keyboard brightness
get_kbd_backlight() {
	echo $(brightnessctl -d '*::kbd_backlight' -m | cut -d, -f4)
}

# Get icons
get_icon() {
	current=$(get_kbd_backlight | sed 's/%//')
	if   [ "$current" -le "20" ]; then
		icon="$iDIR/brightness-20.png"
	elif [ "$current" -le "40" ]; then
		icon="$iDIR/brightness-40.png"
	elif [ "$current" -le "60" ]; then
		icon="$iDIR/brightness-60.png"
	elif [ "$current" -le "80" ]; then
		icon="$iDIR/brightness-80.png"
	else
		icon="$iDIR/brightness-100.png"
	fi
}
# Notify
notify_user() {
	notify-send -e -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$current -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" "Keyboard" "Brightness:$current%"
}

# Change brightness
change_kbd_backlight() {
	brightnessctl -d *::kbd_backlight set "$1" && get_icon && notify_user
}

# Cycle brightness (off -> low -> med -> high -> off)
cycle_kbd_backlight() {
	current=$(get_kbd_backlight | sed 's/%//')
	if [ -z "$current" ] || [ "$current" -eq "0" ]; then
		change_kbd_backlight "33%"
	elif [ "$current" -le "34" ]; then
		change_kbd_backlight "66%"
	elif [ "$current" -le "67" ]; then
		change_kbd_backlight "100%"
	else
		change_kbd_backlight "0"
	fi
}

# Execute accordingly
case "$1" in
	"--get")
		get_kbd_backlight
		;;
	"--inc")
		change_kbd_backlight "+30%"
		;;
	"--dec")
		change_kbd_backlight "30%-"
		;;
	"--cycle")
		cycle_kbd_backlight
		;;
	*)
		get_kbd_backlight
		;;
esac
