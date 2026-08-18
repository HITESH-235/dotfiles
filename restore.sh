#!/bin/bash
set -e
echo "=== Restoring Dotfiles & System Configs ==="

# 1. Restore .config directories
mkdir -p ~/.config
cp -r .config/* ~/.config/
cp .zshrc ~/.zshrc

# 2. Restore GNOME / Dconf settings if dconf is installed
if command -v dconf &> /dev/null; then
    echo "Restoring GNOME / dconf settings..."
    dconf load / < system/dconf-settings.ini
fi

# 3. Install packages if on Arch Linux
if command -v pacman &> /dev/null; then
    echo "To reinstall your Arch packages, run:"
    echo "  sudo pacman -S --needed - < system/pkglist-explicit.txt"
    echo "  yay -S --needed - < system/pkglist-aur.txt"
fi

echo "=== Restoration Complete! ==="
