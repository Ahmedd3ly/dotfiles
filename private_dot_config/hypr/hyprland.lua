-- ██╗░░██╗██╗░░░██╗██████╗░██████╗░██╗░░░░░░█████╗░███╗░░░██╗██████╗░
-- ██║░░██║╚██╗░██╔╝██╔══██╗██╔══██╗██║░░░░░██╔══██╗████╗░░██║██╔══██╗
-- ███████║░╚████╔╝░██████╔╝██████╔╝██║░░░░░███████║██╔██╗░██║██║░░██║
-- ██╔══██║░░╚██╔╝░░██╔═══╝░██╔══██╗██║░░░░░██╔══██║██║╚██╗██║██║░░██║
-- ██║░░██║░░░██║░░░██║░░░░░██║░░██║███████╗██║░░██║██║░╚████║██████╔╝
-- ╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═══╝╚═════╝░
--
-- Entry point only: every concern lives in its own file under ./modules.
-- Environment variables are NOT set here; uwsm loads them before Hyprland
-- starts (~/.config/uwsm/env, ~/.config/uwsm/env-hyprland).
--
-- Wiki: https://wiki.hypr.land/configuring/
-- Keys: /usr/share/hypr/stubs/hl.meta.lua
-- Check after every edit: hyprctl reload && hyprctl configerrors

-- Displays first: everything below assumes the outputs exist.
-- GPU order (AQ_DRM_DEVICES) is set before Hyprland starts, in uwsm/env-hyprland.
require('modules.monitors')    -- outputs, modes, scale, HDR fix, workspace placement

require('modules.input')       -- keyboard, touchpad, gestures
require('modules.look')        -- gaps, borders, rounding, blur, shadows, layout
require('modules.animations')  -- curves and animation leaves
require('modules.rules')       -- window rules
require('modules.binds')       -- keybindings (reads modules/apps.lua)
require('modules.autostart')   -- processes without a systemd unit
