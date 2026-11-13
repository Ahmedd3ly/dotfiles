-- █▀█ █░█ █░░ █▀▀ █▀
-- █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- Why: per-app window behaviour. Workspace placement rules live in
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
