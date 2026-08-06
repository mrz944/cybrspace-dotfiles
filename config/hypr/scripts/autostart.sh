#!/usr/bin/env bash

# Hyprland Master Autostart Script

# Ensure environment is synced across DBus and Systemd
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE

# Polkit Authentication Agent
if command -v hyprpolkitagent >/dev/null 2>&1; then
    hyprpolkitagent >/dev/null 2>&1 &
    disown
elif [ -f /usr/lib/polkit-kde-authentication-agent-1 ]; then
    /usr/lib/polkit-kde-authentication-agent-1 >/dev/null 2>&1 &
    disown
elif [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
    disown
fi

# Headless Display Fallback (Safe no-op if real monitor is connected)
if [ -f "$HOME/.config/hypr/scripts/ensure-headless.sh" ]; then
    "$HOME/.config/hypr/scripts/ensure-headless.sh" &
    disown
fi

# Wallpaper Daemon (hyprpaper)
if [ -f "$HOME/.config/hypr/scripts/wallpaper.sh" ]; then
    "$HOME/.config/hypr/scripts/wallpaper.sh" &
    disown
fi

# Status Bar (Waybar)
killall waybar 2>/dev/null
waybar >/tmp/waybar.log 2>&1 &
disown

# Notification Center & Control Panel (SwayNC)
killall swaync 2>/dev/null
swaync >/tmp/swaync.log 2>&1 &
disown

# Idle & Sleep Manager (Hypridle)
killall hypridle 2>/dev/null
hypridle >/dev/null 2>&1 &
disown

# Clipboard History Manager (Cliphist)
if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
    wl-paste --type text --watch cliphist store &
    disown
    wl-paste --type image --watch cliphist store &
    disown
fi

# Hyprland Plugin Manager (e.g. hyprbars)
if command -v hyprpm >/dev/null 2>&1; then
    hyprpm reload -n >/dev/null 2>&1 &
    disown
fi

# Automount Daemon for Internal/External Storage and USB Drives
if command -v udiskie >/dev/null 2>&1; then
    udiskie --automount --notify --tray &
    disown
fi
