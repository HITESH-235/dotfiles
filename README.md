# Dotfiles

My personal Arch Linux configuration files managed with a bare Git repository.

## Management
I use a custom `config` alias to manage these files without moving them from their home directory.

```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

## How to use
- **Check status:** `config status`
- **Add files:** `config add <file>`
- **Commit changes:** `config commit -m "message"`
- **Push to GitHub:** `config push`

## Tracked Configurations
- **Shell:** Zsh (Oh My Zsh)
- **WM:** Hyprland
- **Bar:** Waybar
- **Terminal:** Ghostty / Kitty
