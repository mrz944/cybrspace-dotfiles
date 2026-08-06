-- #######################################################################################
-- HYPRLAND LUA CONFIGURATION - GRUVBOX THEME
-- #######################################################################################

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 2.0,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "command -v kitty >/dev/null 2>&1 && kitty || alacritty"
local fileManager = "command -v yazi >/dev/null 2>&1 && (command -v kitty >/dev/null 2>&1 && kitty -e yazi || alacritty -e yazi) || nautilus"
local guiFileManager = "nautilus"
local menu = "rofi -show drun -theme ~/.config/rofi/gruvbox.rasi"
local screenshotArea = "~/.config/hypr/scripts/screenshot.sh area"
local screenshotFull = "~/.config/hypr/scripts/screenshot.sh full"
local lockscreen = "hyprlock"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function () 
    hl.exec_cmd("/home/cyberdev/.config/hypr/scripts/autostart.sh")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_SCALE_FACTOR_ROUNDING_POLICY", "PassThrough")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 12,
        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(fabd2fee)", "rgba(fe8019ee)"}, angle = 45 },
            inactive_border = "rgba(3c3836aa)",
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 3,
            color        = 0xee1d2021,
        },

        blur = {
            enabled   = true,
            size      = 5,
            passes    = 2,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- Default curves and animations
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.5,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 3,    bezier = "linear",       style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3.5,  bezier = "easeOutQuint", style = "slide" })

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(guiFileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockscreen))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave || firefox || xdg-open 'https://'"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("zed"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("/home/cyberdev/.config/hypr/scripts/wallpaper.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("/home/cyberdev/.config/hypr/scripts/wallpaper_selector.sh"))
-- Window Management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshotArea))
hl.bind("PRINT", hl.dsp.exec_cmd(screenshotFull))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(screenshotArea))

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- Move active window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Exit Hyprland
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { locked = true, repeating = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- Display Scaling shortcuts
hl.bind(mainMod .. " + CTRL + equal", hl.dsp.exec_cmd("/home/cyberdev/.config/hypr/scripts/adjust-scale.sh up"))
hl.bind(mainMod .. " + CTRL + minus", hl.dsp.exec_cmd("/home/cyberdev/.config/hypr/scripts/adjust-scale.sh down"))

--------------------------------
---- WINDOW RULES & LAYERS -----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
    size  = "800 500",
})

hl.window_rule({
    name   = "opensnitch-prompts",
    match  = { class = "^(?i)opensnitch.*" },
    float  = true,
    center = true,
})

--------------------------------
------ HYPRBARS PLUGIN ---------
--------------------------------
hl.config({
    plugin = {
        hyprbars = {
            bar_height = 26,
            bar_color = "rgb(282828)",
            bar_text_font = "JetBrains Mono Nerd Font",
            bar_text_size = 10,
            bar_text_align = "center",
            bar_buttons_alignment = "left",
            bar_part_of_window = true,
            bar_precedence_over_border = true,
            bar_padding = 10,
            bar_button_padding = 6,
            icon_on_hover = false,
            on_double_click = "hyprctl dispatch fullscreen 1",
            ["col.text"] = "rgb(ebdbb2)",
        }
    }
})

-- macOS style traffic light buttons
if hl.plugin and hl.plugin.hyprbars and hl.plugin.hyprbars.add_button then
    -- Red: Close
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(fb4934)",
        fg_color = "rgb(282828)",
        size = 10,
        icon = "",
        action = "hyprctl dispatch killactive",
    })
    -- Yellow: Float / Tile
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(fabd2f)",
        fg_color = "rgb(282828)",
        size = 10,
        icon = "",
        action = "hyprctl dispatch togglefloating",
    })
    -- Green: Fullscreen / Maximize
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(b8bb26)",
        fg_color = "rgb(282828)",
        size = 10,
        icon = "",
        action = "hyprctl dispatch fullscreen 1",
    })
end


