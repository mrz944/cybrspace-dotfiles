#!/usr/bin/env bash
set -e

# ##############################################################################
# CYBRSPACE // Modern Gruvbox Hyprland Desktop Environment (Lua)
# ##############################################################################

# Color Palette
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
BOLD="\033[1m"
RESET="\033[0m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config"
BACKUP_DIR="$HOME/.config/cybrspace_backup_$(date +%Y%m%d_%H%M%S)"

# Header Banner
print_banner() {
    clear
    echo -e "${YELLOW}${BOLD}"
    cat << "EOF"
  ██████╗██╗   ██╗██████╗ ██████╗ ███████╗██████╗  █████╗  ██████╗███████╗
 ██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
 ██║      ╚████╔╝ ██████╔╝██████╔╝███████╗██████╔╝███████║██║     █████╗  
 ██║       ╚██╔╝  ██╔══██╗██╔══██╗╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝  
 ╚██████╗   ██║   ██████╔╝██║  ██║███████║██║     ██║  ██║╚██████╗███████╗
  ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝
           NATIVE LUA HYPRLAND DESKTOP ENVIRONMENT INSTALLER
EOF
    echo -e "${RESET}"
    echo -e "${CYAN}----------------------------------------------------------------------${RESET}"
}

# Helper logger functions
info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}[ERR]${RESET}  $*"; }

# 1. Check Package Manager
detect_aur_helper() {
    if command -v yay >/dev/null 2>&1; then
        echo "yay"
    elif command -v paru >/dev/null 2>&1; then
        echo "paru"
    else
        echo "pacman"
    fi
}

# 2. Package Installation
install_packages() {
    info "Checking and installing required system packages..."
    HELPER=$(detect_aur_helper)
    PKG_FILE="$DOTFILES_DIR/packages.txt"

    if [ -f "$PKG_FILE" ]; then
        # Read package names omitting comments and blank lines
        mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$PKG_FILE")

        if [ "$HELPER" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${PKGS[@]}" || warn "Some packages might require an AUR helper (yay/paru)."
        else
            "$HELPER" -S --needed --noconfirm "${PKGS[@]}"
        fi
        success "Packages installed successfully."
    else
        warn "Package manifest ($PKG_FILE) not found, skipping package installation."
    fi
}

# 3. Backup Existing Configs
backup_existing() {
    info "Backing up current configurations to ${BACKUP_DIR}..."
    mkdir -p "$BACKUP_DIR"

    for app in hypr waybar swaync rofi kitty alacritty yazi btop nwg-dock-hyprland; do
        if [ -d "$HOME/.config/$app" ] || [ -f "$HOME/.config/$app" ]; then
            cp -r "$HOME/.config/$app" "$BACKUP_DIR/"
            success "Backed up ~/.config/$app"
        fi
    done
    success "Backup complete."
}

# 4. Deploy Config Files
deploy_configs() {
    info "Deploying Gruvbox configurations to ~/.config/..."
    mkdir -p "$HOME/.config"

    # Copy configurations
    for dir in "$CONFIG_DIR"/*; do
        app_name=$(basename "$dir")
        mkdir -p "$HOME/.config/$app_name"
        cp -rf "$dir/"* "$HOME/.config/$app_name/"
        success "Deployed ~/.config/$app_name"
    done

    # Remove any existing legacy hyprland.conf to ensure Hyprland boots into native Lua mode
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        warn "Removing legacy ~/.config/hypr/hyprland.conf to enforce hyprland.lua..."
        rm -f "$HOME/.config/hypr/hyprland.conf"
    fi

    # Ensure scripts have execute permissions
    chmod +x "$HOME"/.config/hypr/scripts/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/waybar/scripts/*.sh 2>/dev/null || true
    success "Config scripts set as executable."
}

# 5. Build and Enable Hyprland Plugins (hyprbars)
install_plugins() {
    if command -v hyprpm >/dev/null 2>&1; then
        info "Configuring hyprbars plugin via hyprpm..."
        hyprpm update || true
        hyprpm add https://github.com/hyprwm/hyprland-plugins 2>/dev/null || true
        hyprpm enable hyprbars 2>/dev/null || true
        hyprpm reload 2>/dev/null || true
        success "hyprbars plugin configured."
    fi
}

# 6. Deploy Binaries & CLI Tools
deploy_binaries() {
    info "Installing syspower and custom CLI utilities to ~/.local/bin/..."
    mkdir -p "$HOME/.local/bin"
    if [ -d "$DOTFILES_DIR/bin" ]; then
        cp -rf "$DOTFILES_DIR/bin/"* "$HOME/.local/bin/"
        chmod +x "$HOME"/.local/bin/* 2>/dev/null || true
        success "Installed utilities: $(ls "$DOTFILES_DIR/bin" | tr '\n' ' ')"
    fi
}

# 7. Deploy Wallpapers
deploy_wallpapers() {
    info "Deploying wallpapers to ~/Pictures/Wallpapers/..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        cp -rf "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/"
        success "Wallpapers copied to ~/Pictures/Wallpapers/"
    fi
}

# 8. Apply Power Optimizations
apply_power_tweaks() {
    if [ -f "$DOTFILES_DIR/setup-power.sh" ]; then
        info "Running power optimization suite (PCIe ASPM, CPU EPP)..."
        sudo bash "$DOTFILES_DIR/setup-power.sh"
    fi
}

# Main Execution Flow
main() {
    print_banner

    echo -e "${BOLD}Select installation mode:${RESET}"
    echo -e "  ${GREEN}1)${RESET} Full Installation (Packages + Configs + Plugins + Wallpapers + Power)"
    echo -e "  ${GREEN}2)${RESET} Configs & Wallpapers Only (No package manager calls)"
    echo -e "  ${GREEN}3)${RESET} Power Optimizations Only"
    echo -e "  ${GREEN}4)${RESET} Exit"
    echo ""
    read -rp "Enter choice [1-4] (default: 1): " choice
    choice=${choice:-1}

    case "$choice" in
        1)
            backup_existing
            install_packages
            deploy_configs
            install_plugins
            deploy_binaries
            deploy_wallpapers
            apply_power_tweaks
            ;;
        2)
            backup_existing
            deploy_configs
            install_plugins
            deploy_binaries
            deploy_wallpapers
            ;;
        3)
            apply_power_tweaks
            ;;
        4)
            info "Installation aborted."
            exit 0
            ;;
        *)
            error "Invalid option selected."
            exit 1
            ;;
    esac

    echo ""
    echo -e "${CYAN}----------------------------------------------------------------------${RESET}"
    echo -e "${GREEN}${BOLD}🎉 Installation Complete!${RESET}"
    echo -e "${BOLD}To apply the changes:${RESET}"
    echo -e "  - Reload / Restart Hyprland: ${CYAN}hyprctl dispatch exit${RESET}"
    echo -e "  - Switch Wallpaper:          ${CYAN}~/.config/hypr/scripts/wallpaper.sh${RESET}"
    echo -e "  - Check System Power:        ${CYAN}syspower -w${RESET}"
    echo -e "${CYAN}----------------------------------------------------------------------${RESET}"
}

main "$@"
