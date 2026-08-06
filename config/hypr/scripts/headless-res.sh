#!/usr/bin/env bash
# headless-res.sh - Adapt display resolution & scale dynamically when Moonlight connects
# Environment variables provided by Sunshine:
# SUNSHINE_CLIENT_WIDTH, SUNSHINE_CLIENT_HEIGHT, SUNSHINE_CLIENT_FPS

ACTION="${1:-set}"
WIDTH="${SUNSHINE_CLIENT_WIDTH:-0}"
HEIGHT="${SUNSHINE_CLIENT_HEIGHT:-0}"
FPS="${SUNSHINE_CLIENT_FPS:-60}"

# Default scale for normal desktop (without stream)
DEFAULT_DESKTOP_SCALE="1.50"

# Determine target monitor (prefer HEADLESS-1 if present, otherwise first available monitor)
TARGET_MONITOR=$(hyprctl monitors -j | jq -r '.[0].name // empty')

if [ -z "$TARGET_MONITOR" ]; then
    # If no monitor exists at all, create headless
    hyprctl output create headless HEADLESS-1
    TARGET_MONITOR="HEADLESS-1"
fi

# Detect current physical monitor resolution if client width is not set
if [ "$WIDTH" -eq 0 ] || [ "$HEIGHT" -eq 0 ]; then
    CURRENT_MODE=$(hyprctl monitors -j | jq -r '.[0].availableModes[0] // "3840x2160@60"')
    WIDTH=$(echo "$CURRENT_MODE" | awk -Fx '{print $1}')
    HEIGHT=$(echo "$CURRENT_MODE" | awk -Fx '{print $2}' | awk -F@ '{print $1}')
fi

# Determine higher UI scaling for Sunshine streaming session:
# - 4K (3840x2160): 2.0x (crisp 1080p HiDPI for laptops)
# - 2560x1600 / 2560x1664 (MacBook Retina): 1.66x / 1.75x
# - 1080p: 1.25x
if [ "$WIDTH" -ge 3840 ] || [ "$HEIGHT" -ge 2160 ]; then
    STREAM_SCALE="2.0"
elif [ "$WIDTH" -ge 2560 ] || [ "$HEIGHT" -ge 1600 ]; then
    STREAM_SCALE="1.66"
elif [ "$WIDTH" -ge 1920 ]; then
    STREAM_SCALE="1.25"
else
    STREAM_SCALE="1.0"
fi

set_monitor_mode() {
    local mon="$1"
    local mode="$2"
    local scale="$3"
    
    echo "Applying monitor configuration: output='$mon', mode='$mode', scale=$scale"
    hyprctl eval "hl.monitor({ output = '${mon}', mode = '${mode}', position = 'auto', scale = ${scale} })" 2>/dev/null || \
    hyprctl keyword monitor "${mon},${mode},auto,${scale}" 2>/dev/null || true
}

case "$ACTION" in
    set)
        echo "Sunshine stream connected: setting $TARGET_MONITOR to ${WIDTH}x${HEIGHT}@${FPS} with scale ${STREAM_SCALE}..."
        # Pause hypridle so inactivity lock is postponed during active streaming
        pkill -STOP hypridle 2>/dev/null || true
        # Unlock screen if locked
        pkill -9 hyprlock 2>/dev/null || true
        loginctl unlock-session 2>/dev/null || true
        
        # Apply mode and higher scaling
        set_monitor_mode "$TARGET_MONITOR" "${WIDTH}x${HEIGHT}@${FPS}" "$STREAM_SCALE"
        ;;
    reset)
        echo "Sunshine stream disconnected: restoring default scale ${DEFAULT_DESKTOP_SCALE}..."
        # Resume hypridle
        pkill -CONT hypridle 2>/dev/null || true
        if [ "$TARGET_MONITOR" = "HEADLESS-1" ]; then
            set_monitor_mode "HEADLESS-1" "1920x1080@60" "1.0"
        else
            set_monitor_mode "$TARGET_MONITOR" "preferred" "$DEFAULT_DESKTOP_SCALE"
        fi
        ;;
esac
