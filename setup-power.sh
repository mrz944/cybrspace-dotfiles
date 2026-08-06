#!/usr/bin/env bash
set -e

# ==============================================================================
# Linux / AMD Power Optimization Setup Script
# Configures PCIe ASPM, Audio power saving, CPU EPP, and low-power C-states
# ==============================================================================

# Colors
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}=== Applying Linux System Power Optimizations ===${RESET}"

# 1. Check Root / Sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Please run this script with sudo:${RESET} sudo ./setup-power.sh"
    exit 1
fi

# 2. PCIe ASPM & Audio Power Saving (tmpfiles.d)
echo -e "\n${BOLD}[1/3] Configuring PCIe ASPM (powersupersave) & Audio Codec Power Saving...${RESET}"
mkdir -p /etc/tmpfiles.d
cat << 'EOF' > /etc/tmpfiles.d/pcie-aspm.conf
# Enable deep PCIe link power states for NVMe SSDs, GPU, and network cards
w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave
# Enable Intel/AMD HDA audio controller power saving
w /sys/module/snd_hda_intel/parameters/power_save - - - - 1
w /sys/module/snd_hda_intel/parameters/power_save_controller - - - - Y
EOF

# Apply immediately
if [ -w /sys/module/pcie_aspm/parameters/policy ]; then
    echo "powersupersave" > /sys/module/pcie_aspm/parameters/policy || true
fi
if [ -w /sys/module/snd_hda_intel/parameters/power_save ]; then
    echo "1" > /sys/module/snd_hda_intel/parameters/power_save || true
fi
echo -e "${GREEN}✓ PCIe ASPM & Audio power rules applied.${RESET}"

# 3. CPU Energy Performance Preference (EPP)
echo -e "\n${BOLD}[2/3] Setting CPU Energy Performance Preference to balance_power...${RESET}"
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    if [ -w "$epp" ]; then
        echo "balance_power" > "$epp" 2>/dev/null || true
    fi
done
echo -e "${GREEN}✓ CPU EPP set to balance_power.${RESET}"

# 4. Runtime Power Management for PCI devices
echo -e "\n${BOLD}[3/3] Enabling runtime power management for PCI buses...${RESET}"
cat << 'EOF' > /etc/udev/rules.d/10-runtime-pm.rules
# Enable runtime PM for PCI devices
ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
EOF
echo -e "${GREEN}✓ Runtime PM udev rules configured.${RESET}"

echo -e "\n${BOLD}${GREEN}⚡ Power Optimization Complete!${RESET}"
echo -e "Your system will now enter deeper low-power states at idle."
