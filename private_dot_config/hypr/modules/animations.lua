-- ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
-- █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█ ▄█
--
-- Why: loads ONE animation preset from ~/.config/hypr/animations/<name>.lua.
-- The choice lives in modules/animation-choice.lua, written by `anim-pick`
-- (SUPER+Shift+Y) and ignored by chezmoi. No choice file = "stock".
-- To freeze a favourite: paste its preset here, delete animations/,
-- anim-pick and the bind. Ref: https://wiki.hypr.land/configuring/core/animations/

local ok, choice = pcall(require, 'modules.animation-choice')
local preset = (ok and type(choice) == 'string') and choice or 'stock'

if not pcall(require, 'animations.' .. preset) then
    require('animations.stock') -- unknown or broken preset: fall back, never break the config
end
