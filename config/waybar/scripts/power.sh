#!/usr/bin/env bash

# Fast Total System Power Estimator for Waybar
# Direct sysfs reads without heavy forks

# 1. GPU Power (Watts)
GPU_POWER_W=0
for p in /sys/class/drm/card*/device/hwmon/hwmon*/power1_average /sys/class/drm/card*/device/hwmon/hwmon*/power1_input; do
    if [ -r "$p" ]; then
        UW=$(cat "$p" 2>/dev/null)
        if [ -n "$UW" ] && [ "$UW" -gt 0 ]; then
            GPU_POWER_W=$((UW / 1000000))
            break
        fi
    fi
done

# 2. CPU Usage & Package Power Calculation
CPU_IDLE=100
if [ -r /proc/stat ]; then
    read -r _ c_user c_nice c_sys c_idle c_iowait c_irq c_softirq _ < /proc/stat
    total=$((c_user + c_nice + c_sys + c_idle + c_iowait + c_irq + c_softirq))
    
    if [ -f /dev/shm/power_cpu_prev ]; then
        read -r p_total p_idle < /dev/shm/power_cpu_prev
        d_total=$((total - p_total))
        d_idle=$((c_idle - p_idle))
        if [ "$d_total" -gt 0 ]; then
            CPU_IDLE=$(( (d_idle * 100) / d_total ))
        fi
    fi
    echo "$total $c_idle" > /dev/shm/power_cpu_prev
fi
CPU_USAGE=$((100 - CPU_IDLE))

# Dynamic Power Calculations
CPU_POWER_W=$(( 18 + (CPU_USAGE * 47) / 100 ))
[ "$GPU_POWER_W" -eq 0 ] && GPU_POWER_W=12
BASE_BOARD_W=15
TOTAL_POWER_W=$(( GPU_POWER_W + CPU_POWER_W + BASE_BOARD_W ))

TEXT="<span font='16.5px'>󱐋</span> ${TOTAL_POWER_W}W"
TOOLTIP="<b>System Total Power:</b> ${TOTAL_POWER_W} W\n- GPU Draw: ${GPU_POWER_W} W\n- CPU Package: ~${CPU_POWER_W} W\n- Motherboard + Drives: ~${BASE_BOARD_W} W"

printf '{"text": "%s", "tooltip": "%s", "percentage": %d, "class": "power"}\n' "$TEXT" "$TOOLTIP" "$TOTAL_POWER_W"
