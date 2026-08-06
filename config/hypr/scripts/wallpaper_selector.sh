#!/usr/bin/env bash

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"

# Find all wallpapers (static and animated)
WALLS=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort)

if [ -z "$WALLS" ]; then
    notify-send "Wallpapers" "No wallpapers found in $WALLPAPERS_DIR"
    exit 0
fi

# Build menu list
MENU=""
while IFS= read -r wall; do
    REL_NAME="${wall#$WALLPAPERS_DIR/}"
    MENU+="$REL_NAME\n"
done <<< "$WALLS"

# Prompt user via Rofi
CHOSEN=$(echo -e "$MENU" | sed '/^$/d' | rofi -dmenu -i -p "🖼️ Choose Wallpaper" -theme ~/.config/rofi/gruvbox.rasi)

if [ -n "$CHOSEN" ]; then
    TARGET="$WALLPAPERS_DIR/$CHOSEN"
    if [ -f "$TARGET" ]; then
        "$HOME/.config/hypr/scripts/wallpaper.sh" "$TARGET"
        notify-send -i "$TARGET" "Wallpaper Changed" "$CHOSEN" 2>/dev/null || notify-send "Wallpaper Changed" "$CHOSEN"
    fi
fi
