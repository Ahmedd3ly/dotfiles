-- ▄▀█ █▀█ █▀█ █▀
-- █▀█ █▀▀ █▀▀ ▄█
--
-- Why: default programs, defined once and required by binds (and later
-- autostart). Plain values, no environment lookups.

return {
    terminal    = "kitty",
    fileManager = "thunar",
    browser     = "firefox",
    editor      = "kitty -e nvim",
    launcher    = "rofi -show drun",
}
