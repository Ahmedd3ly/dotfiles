#!/bin/sh
# █░█ █▄░█ █ ▀█▀ █▀
# █▄█ █░▀█ █ ░█░ ▄█
#
# Why: session services that ship systemd user units are enabled here, so a
# fresh machine gets them from `chezmoi apply`. They are WantedBy
# graphical-session.target, which uwsm starts with Hyprland.
# chezmoi re-runs this script whenever its content changes; `enable` is
# idempotent. Add a unit here when its config lands in the repo.
# ssh-agent.service ships with openssh (WantedBy=default.target, so it starts
# at login, before the graphical session): holds the unlocked SSH key, so the
# passphrase is asked once per login (see ~/.ssh/config AddKeysToAgent).
# crash-notify.path (ours, ~/.config/systemd/user): crash notifications.
# battery-notify.timer (ours): low-battery alerts.
set -eu

systemctl --user enable \
    hyprpolkitagent.service \
    cliphist.service \
    mako.service \
    hypridle.service \
    hyprsunset.service \
    waybar.service \
    ssh-agent.service \
    crash-notify.path \
    battery-notify.timer
