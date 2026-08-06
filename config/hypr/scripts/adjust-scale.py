#!/usr/bin/env python3
import sys
import json
import subprocess
import os

STATE_FILE = "/run/user/1000/hypr_scale_state"
# Standard DRM/Hyprland integer and pixel-aligned fractional steps
STEPS = [1.0, 1.25, 1.5, 1.67, 2.0, 2.4, 2.5, 3.0]

def get_current_scale():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                val = float(f.read().strip())
                if 0.5 <= val <= 4.0:
                    return val
        except Exception:
            pass

    try:
        raw_json = subprocess.check_output(["hyprctl", "monitors", "-j"], timeout=2)
        monitors = json.loads(raw_json.decode("utf-8"))
        if monitors and isinstance(monitors, list):
            for mon in monitors:
                if mon.get("focused"):
                    return float(mon.get("scale", 2.0))
            return float(monitors[0].get("scale", 2.0))
    except Exception:
        pass

    return 2.0

def get_target_monitor():
    try:
        raw_json = subprocess.check_output(["hyprctl", "monitors", "-j"], timeout=2)
        monitors = json.loads(raw_json.decode("utf-8"))
        if monitors and isinstance(monitors, list):
            for mon in monitors:
                if mon.get("focused"):
                    return mon.get("name", "")
            return monitors[0].get("name", "")
    except Exception:
        pass
    return ""

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "up"
    curr_scale = get_current_scale()
    mon_name = get_target_monitor()

    # Find closest step
    closest_idx = min(range(len(STEPS)), key=lambda i: abs(STEPS[i] - curr_scale))

    if action in ("up", "+", "+0.1", "+1"):
        new_idx = min(len(STEPS) - 1, closest_idx + 1)
        new_scale = STEPS[new_idx]
    elif action in ("down", "-", "-0.1", "-1"):
        new_idx = max(0, closest_idx - 1)
        new_scale = STEPS[new_idx]
    elif action == "reset":
        new_scale = 2.0
    else:
        try:
            val = float(action)
            new_scale = min(STEPS, key=lambda x: abs(x - val))
        except ValueError:
            new_scale = 2.0

    # Persist chosen scale step
    try:
        with open(STATE_FILE, "w") as f:
            f.write(str(new_scale))
    except Exception:
        pass

    # Apply via Hyprland Lua eval (zero warnings, fully native)
    if mon_name:
        lua_cmd = f"hl.monitor({{ output = '{mon_name}', mode = 'preferred', position = 'auto', scale = {new_scale} }})"
    else:
        lua_cmd = f"hl.monitor({{ output = '', mode = 'preferred', position = 'auto', scale = {new_scale} }})"

    subprocess.run(["hyprctl", "eval", lua_cmd], capture_output=True)

    # Toast notification (Icon 2: Info, 1200ms duration, Gruvbox accent)
    pct = int(round(new_scale * 100))
    subprocess.run(["hyprctl", "notify", "2", "1200", "rgb(fabd2f)", f"Display Scale: {new_scale:.2f}x ({pct}%)"], capture_output=True)
    return 0

if __name__ == "__main__":
    sys.exit(main())
