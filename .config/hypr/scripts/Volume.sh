#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic 

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# Get Volume
get_volume() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    local hw_volume
    hw_volume=$(pamixer --get-volume)
    
    local ui_volume
    ui_volume=$hw_volume
    
    if [[ "$ui_volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$ui_volume %"
    fi
}

# Get icons
get_icon() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "$iDIR/volume-mute.png"
        return
    fi

    local ui_volume
    ui_volume=$(get_volume | cut -d' ' -f1)
    
    if [[ "$ui_volume" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "$ui_volume" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

# Notify
notify_user() {
    local muted="$(pamixer --get-mute)"
    local ui_volume
    ui_volume=$(get_volume | cut -d' ' -f1)

    if [[ "$muted" == "true" || "$ui_volume" -eq 0 ]]; then
        notify-send -e -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
            " Volume:" " Muted"
    else
        notify-send -e -h int:value:"$ui_volume" -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
            " Volume Level:" " ${ui_volume}%" &&
            "$sDIR/Sounds.sh" --volume
    fi
    pkill -RTMIN+8 waybar
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        # Increase HW volume by 5%
        pamixer -i 5 --set-limit 100 && notify_user
    fi
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -d 5 --set-limit 100 && notify_user
    fi
}

# Toggle Mute
toggle_mute() {
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/volume-mute.png" " Mute"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$(get_icon)" " Volume:" " Switched ON"
	fi
}

# Toggle Mic
toggle_mic() {
	if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
		pamixer --default-source -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF"
	elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
		pamixer --default-source -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone.png" " Microphone:" " Switched ON"
	fi
}
# Get Mic Icon
get_mic_icon() {
    local muted="$(pamixer --default-source --get-mute)"
    local ui_volume
    ui_volume=$(get_mic_volume | cut -d' ' -f1)
    
    if [[ "$muted" == "true" || "$ui_volume" -eq "0" ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

# Get Microphone Volume
get_mic_volume() {
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    local hw_volume
    hw_volume=$(pamixer --default-source --get-volume)
    
    local ui_volume
    ui_volume=$hw_volume
    
    if [[ "$ui_volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$ui_volume %"
    fi
}

# Notify for Microphone
notify_mic_user() {
    local muted="$(pamixer --default-source --get-mute)"
    local ui_volume
    ui_volume=$(get_mic_volume | cut -d' ' -f1)
    local icon

    if [[ "$muted" == "true" || "$ui_volume" -eq 0 ]]; then
        icon="$iDIR/microphone-mute.png"
        notify-send -e -h "string:x-canonical-private-synchronous:volume_notif" \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" \
            " Mic Level:" " Muted"
    else
        icon="$iDIR/microphone.png"
        notify-send -e -h int:value:"$ui_volume" -h "string:x-canonical-private-synchronous:volume_notif" \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" \
            " Mic Level:" " ${ui_volume}%"
    fi
    pkill -RTMIN+8 waybar
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5 --set-limit 100 && notify_mic_user
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -d 5 --set-limit 100 && notify_mic_user
    fi
}


# Waybar modules
get_waybar_volume() {
    local muted="$(pamixer --get-mute)"
    local ui_volume=$(get_volume | cut -d' ' -f1)
    
    if [[ "$muted" == "true" || "$ui_volume" == "Muted" ]]; then
        echo '{"text": "󰖁 Muted", "tooltip": "Muted", "class": "muted"}'
    else
        local icon=""
        if [[ "$ui_volume" -le 30 ]]; then icon=""; elif [[ "$ui_volume" -le 60 ]]; then icon="󰕾"; fi
        echo "{\"text\": \"$icon $ui_volume%\", \"tooltip\": \"Volume: $ui_volume%\", \"class\": \"unmuted\"}"
    fi
}

get_waybar_mic_volume() {
    local muted="$(pamixer --default-source --get-mute)"
    local ui_volume=$(get_mic_volume | cut -d' ' -f1)
    
    if [[ "$muted" == "true" || "$ui_volume" == "Muted" ]]; then
        echo '{"text": " Muted", "tooltip": "Mic Muted", "class": "muted"}'
    else
        echo "{\"text\": \" $ui_volume%\", \"tooltip\": \"Mic: $ui_volume%\", \"class\": \"unmuted\"}"
    fi
}
# Execute accordingly
case "$1" in
"--get")
  get_volume
  ;;
"--inc")
  inc_volume
  ;;
"--inc-precise")
  pamixer -i 2 --set-limit 100 && notify_user
  ;;
"--dec")
  dec_volume
  ;;
"--dec-precise")
  pamixer -d 2 --set-limit 100 && notify_user
  ;;
"--toggle")
  toggle_mute
  ;;
"--toggle-mic")
  toggle_mic
  ;;
"--get-icon")
  get_icon
  ;;
"--get-mic-icon")
  get_mic_icon
  ;;
"--mic-inc")
  inc_mic_volume
  ;;
"--mic-dec")
  dec_mic_volume
  ;;
"--waybar-volume")
  get_waybar_volume
  ;;
"--waybar-mic")
  get_waybar_mic_volume
  ;;
*)
  get_volume
  ;;
esac
