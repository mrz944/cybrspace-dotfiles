#!/usr/bin/env bash

# CYBRSPACE - HDMI Monitor Brightness via DDC/CI (VCP code 10)
# Architecture:
#   - on-scroll-up/down  -> writes delta to ADJ_FILE (instant, 0ms)
#   - daemon UI loop     -> polls every 30ms, emits JSON to waybar instantly
#   - hw_sync_loop       -> background process, applies queued value over I2C

STEP=5
MIN=5
MAX=100
ICON="󰛨"
ADJ_FILE="/tmp/.monitor_brightness_adj"
CACHE_FILE="/tmp/.monitor_brightness_cache"
LOCK_FILE="/tmp/.monitor_brightness.lock"
HW_PIPE="/tmp/.monitor_brightness_hw"

clamp() {
    local v=$1
    [ "$v" -lt "$MIN" ] && v=$MIN
    [ "$v" -gt "$MAX" ] && v=$MAX
    echo "$v"
}

emit() {
    local val="$1"
    if [ -z "$val" ] || [ "$val" -lt 0 ] 2>/dev/null; then
        printf '{"text": "%s --", "tooltip": "<b>Monitor Brightness:</b> unavailable", "percentage": 0, "class": "monitor"}\n' "$ICON"
        return
    fi
    [ "$val" -gt 100 ] && val=100
    printf '{"text": "%s %s%%", "tooltip": "<b>LG HDR 4K Brightness:</b> %s%%\\n\\nScroll to adjust", "percentage": %s, "class": "monitor"}\n' "$ICON" "$val" "$val" "$val"
}

accumulate() {
    (
        flock -x 9
        local cur=0
        [ -f "$ADJ_FILE" ] && cur=$(cat "$ADJ_FILE" 2>/dev/null || echo 0)
        echo $((cur + $1)) > "$ADJ_FILE"
    ) 9>"$LOCK_FILE"
}

drain_adj() {
    flock -x 9 9>"$LOCK_FILE"
    local adj=0
    [ -f "$ADJ_FILE" ] && adj=$(cat "$ADJ_FILE" 2>/dev/null || echo 0)
    [ "$adj" -ne 0 ] 2>/dev/null && echo 0 > "$ADJ_FILE"
    flock -u 9
    echo "$adj"
}

hw_sync_loop() {
    local last_sent=-1
    while true; do
        if [ -f "$HW_PIPE" ]; then
            local target
            target=$(cat "$HW_PIPE" 2>/dev/null)
            rm -f "$HW_PIPE"
            if [ -n "$target" ] && [ "$target" != "$last_sent" ] 2>/dev/null; then
                ddcutil setvcp 10 "$target" --noverify >/dev/null 2>&1
                last_sent="$target"
            fi
        fi
        sleep 0.15
    done
}

daemon() {
    echo 0 > "$ADJ_FILE"
    rm -f "$HW_PIPE"

    local val
    val=$(ddcutil getvcp 10 --terse 2>/dev/null | awk '{print $4}')
    [ -z "$val" ] && val=50
    echo "$val" > "$CACHE_FILE"
    emit "$val"

    hw_sync_loop &
    local hw_pid=$!
    trap "kill $hw_pid 2>/dev/null; exit 0" EXIT INT TERM

    while true; do
        adj=$(drain_adj)
        if [ -n "$adj" ] && [ "$adj" -ne 0 ] 2>/dev/null; then
            cur=$(cat "$CACHE_FILE" 2>/dev/null || echo 50)
            new=$(clamp $((cur + adj)))
            echo "$new" > "$CACHE_FILE"
            emit "$new"
            echo "$new" > "$HW_PIPE"
        fi
        sleep 0.03
    done
}

case "${1:-}" in
    up)   accumulate "$STEP" ;;
    down) accumulate "-$STEP" ;;
    *)    daemon ;;
esac
