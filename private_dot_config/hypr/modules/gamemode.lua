-- █▀▀ ▄▀█ █▀▄▀█ █▀▀ █▀▄▀█ █▀█ █▀▄ █▀▀
-- █▄█ █▀█ █░▀░█ ██▄ █░▀░█ █▄█ █▄▀ ██▄
--
-- Why: when game mode is on (the `gamemode` script / bar button wrote
-- modules/gamemode-state.lua), drop everything that costs frames. Required
-- last, so it overrides look.lua and the animation preset.

local ok, on = pcall(require, 'modules.gamemode-state')
if not (ok and on == true) then return end

hl.config({
    animations = { enabled = false },
    general    = { gaps_in = 0, gaps_out = 0, border_size = 1 },
    decoration = {
        rounding         = 0,
        active_opacity   = 1,
        inactive_opacity = 1,
        blur             = { enabled = false },
    },
})
