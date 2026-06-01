#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script to clear system and user cache

iDIR="$HOME/.config/swaync/images"

# Run cleanup in kitty to allow sudo password entry
kitty -T "Cache Cleanup" -e bash -c "
    echo 'Starting System Cache Cleanup...'
    echo '--------------------------------'
    
    # Pacman cache
    if command -v pacman &> /dev/null; then
        echo 'Clearing Pacman cache (keeping last 3 versions)...'
        sudo paccache -r || sudo pacman -Sc --noconfirm
    fi
    
    # AUR cache (yay/paru)
    if command -v yay &> /dev/null; then
        echo 'Clearing Yay cache...'
        yay -Sc --noconfirm
    elif command -v paru &> /dev/null; then
        echo 'Clearing Paru cache...'
        paru -Sc --noconfirm
    fi
    
    # User thumbnails
    echo 'Clearing user thumbnails...'
    rm -rf ~/.cache/thumbnails/*
    
    # Wallust cache if applicable
    if [ -d ~/.cache/wallust ]; then
        echo 'Clearing wallust cache...'
        rm -rf ~/.cache/wallust/*
    fi

    echo '--------------------------------'
    echo 'Cleanup complete! Press any key to exit.'
    read -n 1
"

notify-send -i "$iDIR/ja.png" -u low "System Cleanup" "Cache cleared successfully!"
