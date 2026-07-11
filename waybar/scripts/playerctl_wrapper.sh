#!/usr/bin/env bash
FLAG="$HOME/.cache/waybar_playerctl_hide"
if [ -f "$FLAG" ]; then
    echo '{"text": ""}'
else
    exec playerctl -a metadata --format '{"text": "{{markup_escape(artist)}}  {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F
fi
