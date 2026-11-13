-- ▄▀█ █▀█ █▀█ █▀
-- █▀█ █▀▀ █▀▀ ▄█
--
-- Why: default programs, defined once and required by binds (and later
-- autostart). Plain values, no environment lookups.

return {
    terminal    = "kitty",
    fileManager = "thunar",
    browser     = "firefox",
    menu        = "rofi -show run",
}
