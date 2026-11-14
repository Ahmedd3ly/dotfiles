-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░
--
-- Why: only what has NO systemd user unit starts here. Everything that ships
-- a unit (mako, cliphist, hyprpolkitagent, later hypridle, hyprsunset,
-- waybar) is enabled by run_onchange_after_enable-user-units.sh in the repo
-- root and started by uwsm via graphical-session.target: restarts on crash,
-- logs in `journalctl --user -u <unit>`.
-- `uwsm app --` runs each command in its own systemd scope.

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- awww-daemon")                       -- wallpaper; restores the last image
    hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard regular") -- keep copies after the source app closes
end)
