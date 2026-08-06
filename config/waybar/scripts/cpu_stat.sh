#!/usr/bin/env bash

# Ultra-efficient CPU stat for Waybar (0% overhead via RAM delta cache)
CACHE_FILE="/dev/shm/cpu_stat_prev"

# 1. CPU Temperature (Linux sysfs)
TEMP="N/A"
for t in /sys/class/hwmon/hwmon*/temp*_input; do
    NAME=$(cat "$(dirname "$t")/name" 2>/dev/null)
    if [ "$NAME" = "k10temp" ] || [ "$NAME" = "zenpower" ] || [ "$NAME" = "coretemp" ]; then
        VAL=$(cat "$t" 2>/dev/null)
        if [ -n "$VAL" ] && [ "$VAL" -gt 0 ]; then
            TEMP="$((VAL / 1000))°C"
            break
        fi
    fi
done

# 2. Average CPU Clock (Linux sysfs scaling_cur_freq)
SUM_FREQ=0
COUNT=0
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
    [ -r "$f" ] || continue
    KHZ=$(cat "$f" 2>/dev/null)
    if [ -n "$KHZ" ]; then
        SUM_FREQ=$((SUM_FREQ + KHZ))
        COUNT=$((COUNT + 1))
    fi
done

if [ "$COUNT" -gt 0 ]; then
    AVG_MHZ=$((SUM_FREQ / COUNT / 1000))
    if [ "$AVG_MHZ" -ge 1000 ]; then
        GHZ_INT=$((AVG_MHZ / 1000))
        GHZ_DEC=$(( (AVG_MHZ % 1000) / 100 ))
        CLOCK_STR="${GHZ_INT}.${GHZ_DEC}GHz"
    else
        CLOCK_STR="${AVG_MHZ}MHz"
    fi
else
    CLOCK_STR="N/A"
fi

# 3. CPU Usage (%)
read -r _ c_user c_nice c_sys c_idle c_iowait c_irq c_softirq _ < /proc/stat
total=$((c_user + c_nice + c_sys + c_idle + c_iowait + c_irq + c_softirq))

USAGE=0
if [ -f "$CACHE_FILE" ]; then
    read -r p_total p_idle < "$CACHE_FILE"
    d_total=$((total - p_total))
    d_idle=$((c_idle - p_idle))
    if [ "$d_total" -gt 0 ]; then
        IDLE_PCT=$(( (d_idle * 100) / d_total ))
        USAGE=$((100 - IDLE_PCT))
    fi
fi
echo "$total $c_idle" > "$CACHE_FILE"

TEXT="<span font='16.5px'></span> ${USAGE}% <span font='14px'>󰾆</span> ${CLOCK_STR} <span font='14px'>󰔏</span> ${TEMP}"
TOOLTIP="<b>CPU Status:</b>\n- Usage: ${USAGE}%\n- Avg Clock: ${CLOCK_STR}\n- Temperature: ${TEMP}\n- Active Cores: ${COUNT}"

printf '{"text": "%s", "tooltip": "%s", "percentage": %d, "class": "cpu"}\n' "$TEXT" "$TOOLTIP" "$USAGE"
