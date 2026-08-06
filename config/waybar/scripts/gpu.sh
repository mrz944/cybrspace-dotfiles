#!/usr/bin/env bash

# Lightweight GPU hardware monitoring for Waybar (0% CPU sysfs)
CARD_DIR=""
for c in /sys/class/drm/card[0-9]; do
    if [ -f "$c/device/gpu_busy_percent" ]; then
        CARD_DIR="$c/device"
        break
    fi
done

if [ -z "$CARD_DIR" ]; then
    printf '{"text": "<span font=\x2716.5px\x27>󰢮</span> N/A", "tooltip": "GPU not found", "class": "gpu"}\n'
    exit 0
fi

# 1. GPU Utilization (%)
BUSY=$(cat "$CARD_DIR/gpu_busy_percent" 2>/dev/null)
[ -z "$BUSY" ] && BUSY=0

# 2. GPU Core Clock (MHz)
SCLK="N/A"
if [ -f "$CARD_DIR/pp_dpm_sclk" ]; then
    MHZ_VAL=$(grep '\*' "$CARD_DIR/pp_dpm_sclk" 2>/dev/null | grep -o '[0-9]\+Mhz' | head -n 1)
    [ -n "$MHZ_VAL" ] && SCLK="$MHZ_VAL"
fi

# 3. GPU Temperature (°C)
TEMP="N/A"
for t in "$CARD_DIR"/hwmon/hwmon*/temp1_input; do
    if [ -r "$t" ]; then
        VAL=$(cat "$t" 2>/dev/null)
        if [ -n "$VAL" ] && [ "$VAL" -gt 0 ]; then
            TEMP="$((VAL / 1000))°C"
            break
        fi
    fi
done

# 4. GPU Power (Watts)
POWER_W="0W"
for p in "$CARD_DIR"/hwmon/hwmon*/power1_average "$CARD_DIR"/hwmon/hwmon*/power1_input; do
    if [ -r "$p" ]; then
        UW=$(cat "$p" 2>/dev/null)
        if [ -n "$UW" ] && [ "$UW" -gt 0 ]; then
            POWER_W="$((UW / 1000000))W"
            break
        fi
    fi
done

TEXT="<span font='16.5px'>󰢮</span> ${BUSY}% <span font='14px'>󰾆</span> ${SCLK} <span font='14px'>󰔏</span> ${TEMP} <span font='14px'>󱐋</span> ${POWER_W}"
TOOLTIP="<b>GPU Status:</b>\n- Usage: ${BUSY}%\n- Core Clock: ${SCLK}\n- Temperature: ${TEMP}\n- Power Draw: ${POWER_W}"

printf '{"text": "%s", "tooltip": "%s", "percentage": %d, "class": "gpu"}\n' "$TEXT" "$TOOLTIP" "$BUSY"
