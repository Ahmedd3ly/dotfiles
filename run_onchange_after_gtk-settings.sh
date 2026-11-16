#!/bin/sh
# █▀▀ ▀█▀ █▄▀
# █▄█ ░█░ █░█
#
# Why: GTK apps on Wayland read their theme, icons and dark preference from
# gsettings (dconf), which is state, not a file chezmoi can track. This
# script sets it on every machine; chezmoi re-runs it when it changes.
# Keep in step with ~/.config/gtk-{3,4}.0/settings.ini and XCURSOR_THEME in
# ~/.config/uwsm/env.
set -eu

command -v gsettings >/dev/null || exit 0
g="gsettings set org.gnome.desktop.interface"

$g color-scheme  'prefer-dark'           # libadwaita / GTK 4 dark
$g gtk-theme     'adw-gtk3-dark'         # GTK 3 (Thunar)
$g icon-theme    'Tela-circle-dracula'
$g cursor-theme  'Bibata-Modern-Ice'
$g cursor-size   24
