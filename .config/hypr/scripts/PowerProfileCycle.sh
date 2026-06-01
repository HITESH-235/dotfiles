#!/usr/bin/env bash

# This script cycles through power profiles: balanced -> performance -> power-saver -> balanced

current=$(powerprofilesctl get)

case $current in
    balanced)
        powerprofilesctl set performance
        notify-send -i "performance" "Power Profile" "Performance Mode"
        ;;
    performance)
        powerprofilesctl set power-saver
        notify-send -i "power-saver" "Power Profile" "Power Saver Mode"
        ;;
    power-saver)
        powerprofilesctl set balanced
        notify-send -i "balanced" "Power Profile" "Balanced Mode"
        ;;
    *)
        powerprofilesctl set balanced
        notify-send -i "balanced" "Power Profile" "Balanced Mode"
        ;;
esac
