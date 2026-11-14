#!/bin/sh
# █░█ █▄░█ █ ▀█▀ █▀
# █▄█ █░▀█ █ ░█░ ▄█
#
# Why: session services that ship systemd user units are enabled here, so a
# fresh machine gets them from `chezmoi apply`. They are WantedBy
# graphical-session.target, which uwsm starts with Hyprland.
# chezmoi re-runs this script whenever its content changes; `enable` is
# idempotent. Add a unit here when its config lands in the repo.
set -eu

systemctl --user enable \
    hyprpolkitagent.service \
    cliphist.service \
    mako.service \
    hypridle.service
