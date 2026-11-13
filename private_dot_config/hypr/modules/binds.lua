-- █▄▄ █ █▄░█ █▀▄ █▀
-- █▄█ █ █░▀█ █▄▀ ▄█
--
-- Why: every keybinding in one file. Descriptions ("[Group] text") feed the
-- `keyhint` cheat sheet (SUPER+grave). Helper scripts live in ~/.local/bin.
-- Ref: https://wiki.hypr.land/configuring/core/binds/

local apps    = require('modules.apps')
local mainMod = "SUPER"
local exec    = hl.dsp.exec_cmd

-- bind(keys, action, description, extra options)
local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end

local function M(keys) return mainMod .. " + " .. keys end

---- Session ---------------------------------------------------------------
bind(M("L"),                 exec("pidof hyprlock || hyprlock"), "[Session] lock screen")
bind(M("End"),               exec("uwsm stop"),                  "[Session] log out")
bind("CONTROL + ALT + Delete", exec("powermenu"),                "[Session] power menu")
bind(M("SHIFT + R"),         exec("hyprctl reload"),             "[Session] reload config")

---- Windows ---------------------------------------------------------------
bind(M("Q"),     hl.dsp.window.close(),                   "[Window] close")
bind("ALT + F4", hl.dsp.window.close(),                   "[Window] close")
bind(M("T"),     hl.dsp.window.float({ action = "toggle" }), "[Window] toggle floating")
bind(M("F"),     hl.dsp.window.fullscreen(),              "[Window] toggle fullscreen")
bind(M("S"),     hl.dsp.layout("togglesplit"),            "[Window] toggle split")
bind("ALT + Tab", hl.dsp.window.cycle_next(),             "[Window] cycle focus")

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind(M(dir),             hl.dsp.focus({ direction = dir }),       "[Window] focus " .. dir)
    bind(M("CONTROL + " .. dir), hl.dsp.window.move({ direction = dir }), "[Window] move " .. dir, { repeating = true })
end

-- Keyboard resize (30 px steps, held key repeats)
local resize = { right = { 30, 0 }, left = { -30, 0 }, up = { 0, -30 }, down = { 0, 30 } }
for dir, d in pairs(resize) do
    bind(M("SHIFT + " .. dir), hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }),
        "[Window] resize " .. dir, { repeating = true })
end

-- Mouse: hold SUPER and drag
bind(M("mouse:272"), hl.dsp.window.drag(),   "[Window] move with mouse",   { mouse = true })
bind(M("mouse:273"), hl.dsp.window.resize(), "[Window] resize with mouse", { mouse = true })

---- Apps ------------------------------------------------------------------
bind(M("Return"), exec(apps.terminal),    "[Apps] terminal")
bind(M("E"),      exec(apps.fileManager), "[Apps] file manager")
bind(M("B"),      exec(apps.browser),     "[Apps] browser")
bind(M("C"),      exec(apps.editor),      "[Apps] editor")

---- Menus (rofi; a second press closes the open menu) ----------------------
local function menu(cmd) return exec("pkill -x rofi || " .. cmd) end
bind(M("A"),         menu(apps.launcher),            "[Menu] app launcher")
bind(M("Tab"),       menu("rofi -show window"),      "[Menu] window switcher")
bind(M("SHIFT + F"), menu("rofi -show filebrowser"), "[Menu] file browser")
bind(M("grave"),     menu("keyhint"),                "[Menu] keybinding cheat sheet")
bind(M("period"),    menu("emoji-pick"),             "[Menu] emoji to clipboard")
bind(M("V"),         menu("cliphist list | rofi -dmenu -i -p clip | cliphist decode | wl-copy"),
    "[Menu] clipboard history")

---- Utilities -------------------------------------------------------------
bind(M("Space"),     exec("hyprctl switchxkblayout all next"), "[Utility] switch keyboard layout", { locked = true })
bind(M("SHIFT + C"), exec("hyprpicker -an"),  "[Utility] colour picker to clipboard")
bind(M("SHIFT + S"), exec("shot region"),     "[Screenshot] region")
bind(M("CONTROL + S"), exec("shot freeze"),   "[Screenshot] frozen region")
bind(M("P"),         exec("shot monitor"),    "[Screenshot] focused monitor")
bind("Print",        exec("shot all"),        "[Screenshot] all monitors")

---- Workspaces ------------------------------------------------------------
for i = 1, 10 do
    local key = tostring(i % 10) -- 10 maps to key 0
    bind(M(key),             hl.dsp.focus({ workspace = i }),       "[Workspace] go to " .. i)
    bind(M("SHIFT + " .. key), hl.dsp.window.move({ workspace = i }), "[Workspace] move window to " .. i)
    bind(M("ALT + " .. key), hl.dsp.window.move({ workspace = i, silent = true }),
        "[Workspace] move window to " .. i .. " silently")
end

bind(M("SHIFT + CONTROL + Right"), hl.dsp.focus({ workspace = "r+1" }),   "[Workspace] next")
bind(M("SHIFT + CONTROL + Left"),  hl.dsp.focus({ workspace = "r-1" }),   "[Workspace] previous")
bind(M("SHIFT + CONTROL + Down"),  hl.dsp.focus({ workspace = "empty" }), "[Workspace] first empty")
bind(M("CONTROL + ALT + Right"), hl.dsp.window.move({ workspace = "r+1" }), "[Workspace] move window to next")
bind(M("CONTROL + ALT + Left"),  hl.dsp.window.move({ workspace = "r-1" }), "[Workspace] move window to previous")
bind(M("mouse_down"), hl.dsp.focus({ workspace = "e+1" }), "[Workspace] next (scroll)")
bind(M("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }), "[Workspace] previous (scroll)")

---- Hardware keys (locked = also work on the lock screen) -----------------
local vol_up   = exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
local vol_down = exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
local vol_mute = exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
local hold     = { locked = true, repeating = true }

bind("XF86AudioRaiseVolume", vol_up,   "[Hardware] volume up",   hold)
bind("XF86AudioLowerVolume", vol_down, "[Hardware] volume down", hold)
bind("XF86AudioMute",        vol_mute, "[Hardware] mute",        { locked = true })
bind("F11", vol_up,   "[Hardware] volume up",   hold)
bind("F10", vol_down, "[Hardware] volume down", hold)
bind("F9",  vol_mute, "[Hardware] mute",        { locked = true })
bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "[Hardware] mute microphone", { locked = true })

bind("XF86MonBrightnessUp",   exec("brightnessctl -e4 -n2 set 5%+"), "[Hardware] brightness up",   hold)
bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), "[Hardware] brightness down", hold)

bind("XF86AudioPlay",  exec("playerctl play-pause"), "[Media] play/pause", { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), "[Media] play/pause", { locked = true })
bind("XF86AudioNext",  exec("playerctl next"),       "[Media] next",       { locked = true })
bind("XF86AudioPrev",  exec("playerctl previous"),   "[Media] previous",   { locked = true })
