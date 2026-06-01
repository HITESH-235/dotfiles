#!/usr/bin/env bash

# This script sets up a udev rule for the battery charge limit and cleans up old services.
# It requires sudo privileges.

echo "Setting up battery threshold udev rule..."
echo 'SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}="80"' | sudo tee /etc/udev/rules.d/99-battery-limit.rules

echo "Disabling and removing old battery services..."
sudo systemctl disable --now battery-limit.service battery-charge-limit.service 2>/dev/null
sudo rm /etc/systemd/system/battery-limit.service /etc/systemd/system/battery-charge-limit.service 2>/dev/null

echo "Reloading systemd and udev..."
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Verifying threshold..."
cat /sys/class/power_supply/BAT0/charge_control_end_threshold

echo "Done! The battery limit should now persist across reboots."
