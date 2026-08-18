#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Pre-configured Monitor Profiles

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.conf"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"
msg='❗NOTE:❗ This will overwrite $HOME/.config/hypr/monitors.conf'

# Define the list of files to ignore
ignore_files=(
  "README"
)

# Detect active profile by comparing files
active_profile=""
for f in "$monitor_dir"/*.conf; do
    base=$(basename "$f" .conf)
    if [[ " ${ignore_files[@]} " =~ " $base " ]]; then
        continue
    fi
    if cmp -s "$f" "$target"; then
        active_profile="$base"
        break
    fi
done

# List of Monitor Profiles, sorted alphabetically
raw_list=$(find -L "$monitor_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Prepend indicator to active profile
mon_profiles_list=""
while read -r line; do
    if [[ -z "$line" ]]; then
        continue
    fi
    # Ignore files in the ignore list
    is_ignored=false
    for ignored_file in "${ignore_files[@]}"; do
        if [[ "$line" == "$ignored_file" ]]; then
            is_ignored=true
            break
        fi
    done
    if $is_ignored; then
        continue
    fi
    if [[ "$line" == "$active_profile" ]]; then
        mon_profiles_list+="➔ $line"$'\n'
    else
        mon_profiles_list+="$line"$'\n'
    fi
done <<< "$raw_list"

# Rofi Menu
if [[ -n "$active_profile" ]]; then
    chosen_file=$(echo -e -n "$mon_profiles_list" | rofi -i -dmenu -select "➔ $active_profile" -config $rofi_theme -mesg "$msg")
else
    chosen_file=$(echo -e -n "$mon_profiles_list" | rofi -i -dmenu -config $rofi_theme -mesg "$msg")
fi

# Clean up selected filename (remove the pointer prefix)
chosen_file=$(echo "$chosen_file" | sed 's/^➔ //')

if [[ -n "$chosen_file" ]]; then
    full_path="$monitor_dir/$chosen_file.conf"
    cp "$full_path" "$target"
    hyprctl reload
    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded"
fi

sleep 1
${SCRIPTSDIR}/RefreshNoWaybar.sh &