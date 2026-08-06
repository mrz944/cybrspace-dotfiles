#!/usr/bin/env bash

# Hyprland Master Autostart Script

# Ensure environment is synced
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE

# Polkit authentication agent
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

# Headless display fallback
/home/cyberdev/.config/hypr/scripts/ensure-headless.sh &
disown

# Wallpaper daemon (hyprpaper)
/home/cyberdev/.config/hypr/scripts/wallpaper.sh &
disown

# Status Bar (Waybar)
killall waybar 2>/dev/null
waybar >/tmp/waybar.log 2>&1 &
disown

# Notification Center (SwayNC)
killall swaync 2>/dev/null
swaync >/tmp/swaync.log 2>&1 &
disown


# Idle daemon
killall hypridle 2>/dev/null
hypridle >/dev/null 2>&1 &
disown

# Clipboard Manager
wl-paste --type text --watch cliphist store &
disown
wl-paste --type image --watch cliphist store &
disown

# Hyprland Plugin Manager (loads hyprbars)
hyprpm reload -n >/dev/null 2>&1 &
disown

# Automount daemon for internal/external drives and USBs
udiskie --automount --notify --tray &
disown




