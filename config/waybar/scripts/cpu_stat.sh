#!/usr/bin/env bash

# Pure RAM-backed delta calculation (zero-sleep overhead)
CACHE="/dev/shm/cpu_stat_prev"
read -r cpu u n s i io irq sirq st g gn < /proc/stat
cur_total=$((u + n + s + i + io + irq + sirq + st))
cur_idle=$((i + io))

USAGE=0
if [ -f "$CACHE" ]; then
    read -r prev_total prev_idle < "$CACHE"
    total_delta=$((cur_total - prev_total))
    idle_delta=$((cur_idle - prev_idle))
    if [ "$total_delta" -gt 0 ]; then
        USAGE=$(( 100 * (total_delta - idle_delta) / total_delta ))
        [ "$USAGE" -lt 0 ] && USAGE=0
        [ "$USAGE" -gt 100 ] && USAGE=100
    fi
fi
echo "$cur_total $cur_idle" > "$CACHE"

# Max CPU Frequency
MAX_FREQ_KHZ=0
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
    FREQ=$(<"$f")
    [ "$FREQ" -gt "$MAX_FREQ_KHZ" ] && MAX_FREQ_KHZ=$FREQ
done

if [ "$MAX_FREQ_KHZ" -gt 0 ]; then
    FREQ_GHZ=$(awk "BEGIN {printf \"%.1f\", $MAX_FREQ_KHZ/1000000}")
else
    FREQ_GHZ="3.8"
fi

# CPU Temperature (k10temp)
TEMP_RAW=$(cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null || cat /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input 2>/dev/null || echo 45000)
TEMP=$((TEMP_RAW / 1000))

TEXT="<span font='16.5px'>󰍛</span> ${USAGE}% ${FREQ_GHZ}GHz ${TEMP}°C"
TOOLTIP="<b>CPU: AMD Ryzen</b>\n- Usage: ${USAGE}%\n- Boost Clock: ${FREQ_GHZ} GHz\n- Package Temp: ${TEMP}°C"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $USAGE, \"class\": \"cpu\"}"
