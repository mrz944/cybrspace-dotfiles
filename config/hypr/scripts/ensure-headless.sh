#!/usr/bin/env bash
# ensure-headless.sh - Ensure a display output exists in Hyprland
# If no physical monitors are attached (headless boot), create a virtual display.

# Give Hyprland a moment to probe DRM outputs
sleep 1

# Check current monitors
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq '. | length' 2>/dev/null || echo 0)

if [ "$monitor_count" -eq 0 ]; then
    echo "[$(date)] No active monitors found. Creating headless virtual display HEADLESS-1..."
    hyprctl output create headless HEADLESS-1
    hyprctl keyword monitor "HEADLESS-1,1920x1080@60,auto,1"
else
    echo "[$(date)] Active monitor(s) detected ($monitor_count). Headless virtual display not needed."
fi
