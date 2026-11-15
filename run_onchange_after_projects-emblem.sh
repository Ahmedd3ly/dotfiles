#!/bin/sh
# █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀
# █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█
#
# Why: ~/Projects (XDG_PROJECTS_DIR, new in xdg-user-dirs 0.20) has no
# special-folder icon until GLib learns about it. Until then Thunar shows a
# "</>" badge on it: emblem-code from ~/.local/share/icons/hicolor. Thunar
# keeps emblems in gvfs metadata (state), so chezmoi sets it here.
set -eu

dir=$(xdg-user-dir PROJECTS 2>/dev/null || true)
[ -n "$dir" ] && [ "$dir" != "$HOME" ] && [ -d "$dir" ] || exit 0
command -v gio >/dev/null || exit 0

gio set -t stringv "$dir" metadata::emblems emblem-code || true
