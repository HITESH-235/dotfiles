#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# wlogout (Power, Screen Lock, Suspend, etc)

# Set variables for parameters. First numbers corresponts to Monitor Resolution
# i.e 2160 means 2160p
A_2160=600
B_2160=600
A_1600=400
B_1600=400
A_1440=400
B_1440=400
A_1080=200
B_1080=200
A_720=50
B_720=50

# Check if snmenu is already running
if pgrep -x "snmenu" > /dev/null; then
    pkill -x "snmenu"
    exit 0
fi

# Run snmenu
/home/hit235/.local/bin/snmenu &
