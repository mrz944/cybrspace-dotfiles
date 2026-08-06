#!/usr/bin/env bash
set -e

echo "==> Building and enabling hyprbars plugin (macOS style window bars)..."
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprbars
hyprpm reload

echo "==> hyprbars successfully installed and loaded!"
