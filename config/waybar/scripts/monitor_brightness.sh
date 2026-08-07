#!/usr/bin/env bash

# CYBRSPACE - HDMI Monitor Brightness via DDC/CI (VCP code 10)
# Responsive daemon design:
#   - on-scroll-up/down  -> accumulate delta into /tmp file (instant, no I2C)
#   - daemon (no args)   -> applies accumulated delta in one I2C op, ~every 80ms

STEP=5
MIN=5
MAX=100
ICON="󰛨"
ADJ_FILE="/tmp/.monitor_brightness_adj"
LOCK_FILE="/tmp/.monitor_brightness.lock"

clamp() {
    local v=$1
    [ "$v" -lt "$MIN" ] && v=$MIN
    [ "$v" -gt "$MAX" ] && v=$MAX
    echo "$v"
}

get_value() {
    ddcutil getvcp 10 --terse 2>/dev/null | awk '{print $4}'
}

emit() {
    local val="$1"
    if [ -z "$val" ] || [ "$val" -lt 0 ] 2>/dev/null; then
        echo "{\"text\": \"${ICON} --\", \"tooltip\": \"<b>Monitor Brightness:</b> unavailable\\nDDC/CI not responding\", \"percentage\": 0, \"class\": \"monitor\"}"
        return
    fi
    [ "$val" -gt 100 ] && val=100
    local tooltip="<b>LG HDR 4K Brightness:</b> ${val}%\\n\\nScroll to adjust | Click to open DDC panel"
    echo "{\"text\": \"${ICON} ${val}%\", \"tooltip\": \"${tooltip}\", \"percentage\": ${val}, \"class\": \"monitor\"}"
}

accumulate() {
    local delta="$1"
    (
        flock -x 9
        local cur=0
        [ -f "$ADJ_FILE" ] && cur=$(cat "$ADJ_FILE" 2>/dev/null || echo 0)
        echo $((cur + delta)) > "$ADJ_FILE"
    ) 9>"$LOCK_FILE"
}

drain_adj() {
    local adj=0
    (
        flock -x 9
        [ -f "$ADJ_FILE" ] && adj=$(cat "$ADJ_FILE" 2>/dev/null || echo 0)
        if [ "$adj" -ne 0 ] 2>/dev/null; then
            echo 0 > "$ADJ_FILE"
        fi
        echo "$adj"
    ) 9>"$LOCK_FILE"
}

daemon() {
    echo 0 > "$ADJ_FILE"
    emit "$(get_value)"
    while true; do
        adj=$(drain_adj)
        if [ -n "$adj" ] && [ "$adj" -ne 0 ] 2>/dev/null; then
            val=$(get_value)
            if [ -n "$val" ] && [ "$val" -ge 0 ] 2>/dev/null; then
                new=$(clamp $((val + adj)))
                ddcutil setvcp 10 "$new" >/dev/null 2>&1
                emit "$new"
            fi
        fi
        sleep 0.08
    done
}

case "${1:-}" in
    up)   accumulate "$STEP" ;;
    down) accumulate "-$STEP" ;;
    *)    daemon ;;
esac
