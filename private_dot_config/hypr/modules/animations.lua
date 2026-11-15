-- ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
-- █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█ ▄█
--
-- Why: loads ONE animation preset from ~/.config/hypr/animations/<name>.lua.
-- The choice lives in modules/animation-choice.lua, written by `anim-pick`
-- (SUPER+Shift+Y) and ignored by chezmoi. No choice file = DEFAULT below.
-- Kept on purpose as a permanent switcher (decided Nov 2026).
-- Ref: https://wiki.hypr.land/configuring/core/animations/

local ok, choice = pcall(require, 'modules.animation-choice')
local DEFAULT = 'standard' -- used on a fresh machine; anim-pick overrides it
local preset = (ok and type(choice) == 'string') and choice or DEFAULT

if not pcall(require, 'animations.' .. preset) then
    require('animations.stock') -- unknown or broken preset: fall back, never break the config
end
-- Why: several presets spin borderangle with style="loop", which forces a redraw
-- every frame (~20-35 % Hyprland CPU at idle, and it defeats panel self-refresh).
-- Sweep once per focus change instead, whatever preset is active.
hl.animation({leaf = "borderangle", enabled = true, speed = 30, bezier = "default", style = "once"})
