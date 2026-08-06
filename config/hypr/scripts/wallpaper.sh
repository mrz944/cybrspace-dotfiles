#!/usr/bin/env bash

# Pure hyprpaper wallpaper controller (0.0% CPU)
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPERS_DIR"

TARGET="$1"
if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
    TARGET=$(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
fi

[ -z "$TARGET" ] && exit 0

# Ensure hyprpaper daemon is running
if ! pgrep -x "hyprpaper" >/dev/null 2>&1; then
    hyprpaper >/dev/null 2>&1 &
    disown
    sleep 0.2
fi

# Switch wallpaper via Hyprland IPC
hyprctl hyprpaper preload "$TARGET" >/dev/null 2>&1
hyprctl hyprpaper wallpaper ",$TARGET" >/dev/null 2>&1
hyprctl hyprpaper unload all >/dev/null 2>&1

mkdir -p "$HOME/.cache"
echo "$TARGET" > "$HOME/.cache/current_wallpaper"
