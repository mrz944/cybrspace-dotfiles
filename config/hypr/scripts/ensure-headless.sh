#!/usr/bin/env bash

# Safety monitor for headless/Sunshine virtual displays
MONITORS=$(hyprctl monitors 2>/dev/null | grep "Monitor " | wc -l)
if [ "$MONITORS" -eq 0 ]; then
    hyprctl output create headless >/dev/null 2>&1
fi
