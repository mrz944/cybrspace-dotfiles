#!/usr/bin/env bash

# Screenshot helper for Hyprland using grim, slurp, swappy & wl-copy
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$DIR/screenshot_${TIMESTAMP}.png"

mode="$1"

case "$mode" in
    area)
        # Select an area or window
        GEOM=$(slurp)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | tee "$FILENAME" | wl-copy --type image/png
            notify-send "Screenshot Taken" "Area screenshot copied to clipboard and saved to $FILENAME" -i "$FILENAME"
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
        # Full screen screenshot
        grim "$FILENAME"
        wl-copy --type image/png < "$FILENAME"
        notify-send "Screenshot Taken" "Fullscreen capture saved to $FILENAME & copied to clipboard" -i "$FILENAME"
        ;;
esac
