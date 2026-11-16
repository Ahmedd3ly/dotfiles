-- █▀█ █░█ █░░ █▀▀ █▀
-- █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- Why: per-app window and layer behaviour. Workspace placement rules live in
-- monitors.lua. Ref: https://wiki.hypr.land/configuring/core/rules/

-- Apps may not maximize themselves; tiling decides sizes.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag-and-drop ghost windows stealing focus.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Hyprland's own run dialog floats bottom-left.
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Layers (bar, launcher, notifications): frosted-glass blur behind them.
-- ignore_alpha = 0 skips fully transparent pixels, so rounded corners and
-- gaps in the bar don't get a blurred rectangle. Namespaces: waybar,
-- rofi, and mako ("notifications").
local glass = "^(waybar|rofi|notifications)$"

hl.layer_rule({
    name  = "glass-blur",
    match = { namespace = glass },
    blur  = true,
})

hl.layer_rule({
    name         = "glass-ignore-alpha",
    match        = { namespace = glass },
    ignore_alpha = 0,
})

-- Bar only: blur the wallpaper, not windows. Without xray the blur kernel
-- also samples the window right under the bar, so a white browser tab strip
-- bleeds up into it as a bright "reflection". Not for rofi/mako: those float
-- over windows and should frost what is actually behind them.
hl.layer_rule({
    name  = "bar-xray",
    match = { namespace = "^waybar$" },
    xray  = true,
})
