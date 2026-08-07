#!/usr/bin/env bash

# CYBRSPACE - HDMI Monitor Brightness via DDC/CI (VCP code 10)
# Usage:
#   monitor_brightness.sh          -> print JSON for waybar
#   monitor_brightness.sh up       -> increase brightness by step
#   monitor_brightness.sh down     -> decrease brightness by step

STEP=5
MIN=5
MAX=100
ICON="󰛨"

LOCK_FILE="/tmp/.monitor_brightness.lock"
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

get_value() {
    ddcutil getvcp 10 --terse 2>/dev/null | awk '{print $4}'
}

emit() {
    local val="$1"
    if [ -z "$val" ] || [ "$val" -lt 0 ] 2>/dev/null; then
        echo "{\"text\": \"${ICON} --\", \"tooltip\": \"<b>Monitor Brightness:</b> unavailable\\nDDC/CI not responding\", \"percentage\": 0, \"class\": \"monitor\"}"
        return
    fi
    local pct="$val"
    [ "$pct" -gt 100 ] && pct=100
    local tooltip="<b>LG HDR 4K Brightness:</b> ${val}%\\n\\nScroll to adjust | Click to open DDC panel"
    echo "{\"text\": \"${ICON} ${val}%\", \"tooltip\": \"${tooltip}\", \"percentage\": ${pct}, \"class\": \"monitor\"}"
}

case "${1:-}" in
    up|down)
        cur=$(get_value)
        if [ -z "$cur" ] || [ "$cur" -lt 0 ] 2>/dev/null; then
            emit ""
            exit 0
        fi
        if [ "$1" = "up" ]; then
            new=$((cur + STEP))
            [ "$new" -gt "$MAX" ] && new=$MAX
        else
            new=$((cur - STEP))
            [ "$new" -lt "$MIN" ] && new=$MIN
        fi
        ddcutil setvcp 10 "$new" >/dev/null 2>&1
        sleep 0.1
        emit "$new"
        ;;
    *)
        emit "$(get_value)"
        ;;
esac
