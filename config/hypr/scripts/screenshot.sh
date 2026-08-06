#!/usr/bin/env bash

# Screenshot Helper for Hyprland using grim, slurp, swappy & wl-copy
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$DIR/screenshot_${TIMESTAMP}.png"

mode="$1"

case "$mode" in
    area)
        # Interactive selection
        GEOM=$(slurp)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | tee "$FILENAME" | wl-copy --type image/png
            notify-send "Screenshot Taken" "Area screenshot saved & copied to clipboard" -i "$FILENAME"
        fi
        ;;
    edit)
        # Interactive annotation with Swappy
        GEOM=$(slurp)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | swappy -f -
        fi
        ;;
    full|*)
        # Full screen capture
        grim "$FILENAME"
        wl-copy --type image/png < "$FILENAME"
        notify-send "Screenshot Taken" "Fullscreen capture saved & copied to clipboard" -i "$FILENAME"
        ;;
esac
