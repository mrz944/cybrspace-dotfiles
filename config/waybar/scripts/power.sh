#!/usr/bin/env bash

# Direct GPU Power
RAW=$(cat /sys/class/drm/card1/device/hwmon/hwmon3/power1_average 2>/dev/null || cat /sys/class/drm/card1/device/hwmon/hwmon3/power1_input 2>/dev/null || echo 0)
GPU_W=$((RAW / 1000000))

# CPU Usage from RAM cache
CACHE="/dev/shm/cpu_stat_prev"
USAGE=5
if [ -f "$CACHE" ]; then
    read -r total idle < "$CACHE"
fi

CPU_EST_W=$(( 22 + (USAGE * 45) / 100 ))
SYS_BASE_W=15
TOTAL_W=$((GPU_W + CPU_EST_W + SYS_BASE_W))

TEXT="<span font='16.5px'>󱐋</span> ${TOTAL_W}W"
TOOLTIP="<b>System Total Power:</b> ${TOTAL_W} W\n- GPU Draw: ${GPU_W} W\n- CPU Package: ~${CPU_EST_W} W\n- Motherboard + Drives: ~${SYS_BASE_W} W"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $TOTAL_W, \"class\": \"power\"}"
