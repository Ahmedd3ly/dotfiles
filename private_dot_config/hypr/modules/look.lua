-- █░░ █▀█ █▀█ █▄▀
-- █▄▄ █▄█ █▄█ █░█
--
-- Why: the static look (gaps, borders, rounding, blur, shadows) and layout.
-- Colours here are placeholders until Phase 4 (Mocha) and Phase 8 (matugen
-- include). Blur passes/size are the main battery cost: keep them low.

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false, -- read wiki "tearing" before enabling
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- the curves themselves live in animations.lua
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = -1,    -- 0 once awww owns the wallpaper
        disable_hyprland_logo   = false,
    },

    layers = {
        -- new top layers (notifications, rofi) may appear over a fullscreen window
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})
