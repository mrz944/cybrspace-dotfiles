# 🌲 Gruvbox Hyprland Desktop Environment & Installer

A complete, production-ready **Gruvbox Dark** desktop environment for **Hyprland** (v0.56.1+ with native **Lua configuration**), featuring macOS-style window controls, Waybar status bar, SwayNC notification center, Rofi application launcher, terminal configurations, power optimizations, and automated installation scripts.

---

## 🌟 Highlights

- **Native Lua Architecture**: Configured entirely via `hyprland.lua` using Hyprland's modern Lua API.
- **macOS Window Controls**: Native titlebar decoration with traffic light buttons via the `hyprbars` plugin:
  - 🔴 **Red**: Close active window (`killactive`)
  - 🟡 **Yellow**: Toggle floating / tiled layout (`togglefloating`)
  - 🟢 **Green**: Maximize / fullscreen (`fullscreen 1`)
- **Gruvbox Dark Aesthetic**: Handcrafted color palette across Waybar, SwayNC, Rofi, Kitty, Alacritty, Yazi, and Btop.
- **Dynamic Tiling & Floating**: Clean default dynamic tiling with automatic floating for utility dialogs (`pavucontrol`, `opensnitch`, file choosers).
- **Power Optimization Suite**: Custom `syspower` utility and PCIe ASPM / CPU EPP energy-saving tuners for AMD APUs / Ryzen systems.
- **Dynamic Scaling & Wallpapers**: On-the-fly display scale adjustment (<kbd>SUPER</kbd>+<kbd>CTRL</kbd>+<kbd>+</kbd>/<kbd>-</kbd>) and wallpaper rotators with `hyprpaper`.

---

## 📁 Repository Layout

```
hyprland-dotfiles/
├── install.sh                  # Interactive master installer script
├── setup-power.sh              # AMD APU / CPU power optimization suite
├── packages.txt                # Comprehensive package dependency manifest
├── bin/
│   └── syspower                # Custom real-time power / wattage monitoring CLI
├── config/
│   ├── hypr/
│   │   ├── hyprland.lua        # Primary Hyprland Lua configuration
│   │   ├── hyprlock.conf       # Lockscreen styling
│   │   ├── hypridle.conf       # Idle daemon configuration
│   │   ├── hyprpaper.conf      # Wallpaper daemon configuration
│   │   └── scripts/            # Shell utilities (autostart, screenshots, scaling, wallpapers)
│   ├── waybar/                 # Waybar status bar configuration & Gruvbox CSS
│   ├── swaync/                 # Sway Notification Center configuration & CSS
│   ├── rofi/                   # Rofi application launcher & Gruvbox theme
│   ├── kitty/                  # Kitty terminal configuration
│   ├── alacritty/              # Alacritty terminal configuration
│   ├── yazi/                   # Yazi terminal file manager configuration
│   ├── btop/                   # Btop system monitor theme
│   └── nwg-dock-hyprland/      # Floating dock CSS styling
├── wallpapers/                 # Curated Gruvbox wallpapers
└── README.md
```

---

## ⌨️ Keybindings

| Shortcut | Action |
|---|---|
| <kbd>SUPER</kbd> + <kbd>Q</kbd> | Open Kitty Terminal |
| <kbd>SUPER</kbd> + <kbd>SPACE</kbd> / <kbd>SUPER</kbd> + <kbd>R</kbd> | Open Rofi App Launcher |
| <kbd>SUPER</kbd> + <kbd>E</kbd> | Open Yazi Terminal File Manager |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>E</kbd> | Open Nautilus GUI File Manager |
| <kbd>SUPER</kbd> + <kbd>B</kbd> | Open Browser |
| <kbd>SUPER</kbd> + <kbd>Z</kbd> | Open Zed Editor |
| <kbd>SUPER</kbd> + <kbd>N</kbd> | Toggle SwayNC Notification Center |
| <kbd>SUPER</kbd> + <kbd>L</kbd> | Lock Screen (`hyprlock`) |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | Cycle Wallpaper |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>W</kbd> | Open Rofi Wallpaper Selector |
| <kbd>SUPER</kbd> + <kbd>C</kbd> | Close Active Window |
| <kbd>SUPER</kbd> + <kbd>V</kbd> | Toggle Floating / Tiled Window |
| <kbd>SUPER</kbd> + <kbd>F</kbd> | Toggle Fullscreen |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>S</kbd> | Screenshot Area (interactive crop) |
| <kbd>PRINT</kbd> | Screenshot Full Screen |
| <kbd>SUPER</kbd> + <kbd>CTRL</kbd> + <kbd>=</kbd> / <kbd>-</kbd> | Adjust Display Scaling (+0.1 / -0.1) |
| <kbd>SUPER</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Switch Workspace 1 - 10 |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Move Window to Workspace 1 - 10 |

---

## 🚀 Installation

Run the interactive installer to set up packages, configurations, plugins, and wallpapers:

```bash
git clone https://github.com/<your-username>/hyprland-dotfiles.git
cd hyprland-dotfiles
chmod +x install.sh setup-power.sh
./install.sh
```

### Installation Options:
1. **Full Installation**: Installs all required packages via `pacman`/`yay`, backs up existing configs, deploys configurations & wallpapers, configures the `hyprbars` plugin, and applies power optimizations.
2. **Configs & Wallpapers Only**: Safe mode that only backs up and deploys dotfiles without touching system packages.
3. **Power Optimizations Only**: Tunes PCIe ASPM and CPU energy performance policies.
