-- █░░ █▀█ █▀█ █▄▀
-- █▄▄ █▄█ █▄█ █░█
--
-- Why: the static look, ported from HyDE's "Catppuccin Latte" theme
-- (hypr.theme) plus the HyDE defaults it ran on (opacity, dim, snap).
-- Pure look, no packages. The main battery cost is blur: size 6 x 3 passes
-- on every translucent window. Drop passes to 2 if the iGPU runs hot.

-- ACCENTS: the only colours in this file. Phase 8 replaces this table with
-- the matugen-generated one (require('modules.colors')); nothing else changes.
local accent = {
    active   = { colors = { "rgba(dc8a78ff)", "rgba(8839efff)" }, angle = 45 }, -- Latte rosewater -> mauve
    inactive = { colors = { "rgba(7287fdcc)", "rgba(179299cc)" }, angle = 45 }, -- Latte lavender -> teal
}

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 8,
        border_size = 2,

        col = {
            active_border   = accent.active,
            inactive_border = accent.inactive,
        },

        resize_on_border = true,  -- drag window edges to resize
        allow_tearing    = false,
        layout           = "dwindle",

        snap = {                  -- floating windows snap to edges and each other
            enabled      = true,
            respect_gaps = true,
        },
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity     = 0.90, -- HyDE's see-through look; blur fills the gap
        inactive_opacity   = 0.75,
        fullscreen_opacity = 1,
        dim_special        = 0.3,  -- dim the desktop behind a scratchpad

        shadow = {
            enabled = false,       -- Latte theme: flat, no shadows
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            ignore_opacity    = true,  -- blur behind translucent windows too
            xray              = false,
            special           = true,  -- blur behind the scratchpad
        },
    },

    animations = {
        enabled = true, -- the curves themselves live in animations.lua
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = -1,    -- 0 once awww owns the wallpaper (Phase 5)
        disable_hyprland_logo   = false,
    },

    layers = {
        -- new top layers (notifications, rofi) may appear over a fullscreen window
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})
