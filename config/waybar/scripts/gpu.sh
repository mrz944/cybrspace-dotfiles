#!/usr/bin/env bash

# AMD GPU Direct Sysfs
CARD="/sys/class/drm/card1/device"
if [ ! -d "$CARD" ]; then
    CARD=$(ls -d /sys/class/drm/card*/device 2>/dev/null | head -n 1)
fi

USAGE=$(cat "$CARD/gpu_busy_percent" 2>/dev/null || echo 0)

# Temperature
HWMON=$(ls -d "$CARD/hwmon/hwmon"* 2>/dev/null | head -n 1)
TEMP_RAW=$(cat "$HWMON/temp1_input" 2>/dev/null || echo 0)
TEMP=$((TEMP_RAW / 1000))

# VRAM
VRAM_USED_RAW=$(cat "$CARD/mem_info_vram_used" 2>/dev/null || echo 0)
VRAM_TOTAL_RAW=$(cat "$CARD/mem_info_vram_total" 2>/dev/null || echo 0)
VRAM_USED_G=$(awk "BEGIN {printf \"%.1f\", $VRAM_USED_RAW/1073741824}")
VRAM_TOTAL_G=$(awk "BEGIN {printf \"%.1f\", $VRAM_TOTAL_RAW/1073741824}")

# Clock
CLK_RAW=$(cat "$HWMON/freq1_input" 2>/dev/null || echo 0)
if [ "$CLK_RAW" -gt 0 ]; then
    CLK="$((CLK_RAW / 1000000))MHz"
else
    CUR_GFX=$(cat "$CARD/current_gfxclk" 2>/dev/null || echo "800")
    CLK="${CUR_GFX}MHz"
fi

# Power
POWER_RAW=$(cat "$HWMON/power1_average" 2>/dev/null || cat "$HWMON/power1_input" 2>/dev/null || echo 0)
POWER_W=$((POWER_RAW / 1000000))

TEXT="<span font='16.5px'>󰢮</span> ${USAGE}% ${CLK} ${TEMP}°C ${POWER_W}W"
TOOLTIP="<b>GPU: AMD Radeon</b>\n- Usage: ${USAGE}%\n- Clock: ${CLK}\n- Temperature: ${TEMP}°C\n- Power: ${POWER_W} W\n- VRAM: ${VRAM_USED_G}G / ${VRAM_TOTAL_G}G"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $USAGE, \"class\": \"gpu\"}"
