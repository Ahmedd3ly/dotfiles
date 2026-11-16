-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░
--
-- Why: only what has NO systemd user unit starts here. Everything that ships
-- a unit (mako, cliphist, hyprpolkitagent, hypridle, hyprsunset,
-- waybar) is enabled by run_onchange_after_enable-user-units.sh in the repo
-- root and started by uwsm via graphical-session.target: restarts on crash,
-- logs in `journalctl --user -u <unit>`.
-- `uwsm app --` runs each command in its own systemd scope.
--
-- Login = lock: tty1 logs in automatically (getty drop-in, see RUNBOOK.md),
-- so hyprlock is the first thing started, before anything else, and acts as
-- the login screen. Not wrapped in `uwsm app` so it starts with no delay.
-- --immediate-render: draw before the wallpaper loads; --no-fade-in: no fade.
-- Without the autologin drop-in (another machine) this just asks once more.

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock --immediate-render --no-fade-in")     -- first: lock the fresh session
    hl.exec_cmd("uwsm app -- awww-daemon")                       -- wallpaper; restores the last image
    hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard regular") -- keep copies after the source app closes
    hl.exec_cmd("uwsm app -- playerctld daemon")                 -- one "current player" for the bar and media keys
end)
