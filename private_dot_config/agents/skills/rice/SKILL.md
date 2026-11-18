---
name: rice
description: Change or debug Ahmed's Hyprland desktop (bar, launcher, notifications, lock screen, colours, wallpapers, keybinds, window rules). Use for any request about how the desktop looks or behaves.
---

# Rice: how this desktop is built

All paths below are deployed paths; edit them in the chezmoi source
(`chezmoi source-path <file>` prints where), then `chezmoi apply`.

## Map
| Piece | Files | Reload |
|---|---|---|
| Hyprland | ~/.config/hypr/hyprland.lua requires modules/*.lua (monitors, input, look, animations, rules, binds, apps, autostart, gamemode) | `hyprctl reload && hyprctl configerrors` |
| Env | ~/.config/uwsm/env, env-hyprland (read at login) | log out and in |
| Bar | ~/.config/waybar/config.jsonc + modules/*.jsonc, style.css, theme.css | `pkill -USR2 -x waybar` |
| Launcher/menus | ~/.config/rofi/*.rasi, scripts rofi-launch, powermenu, wall-pick | next launch |
| Notifications | ~/.config/mako/config | `makoctl reload` |
| Lock | ~/.config/hypr/hyprlock.conf (hyprlang, not Lua: its own format) | next lock |
| Terminal | ~/.config/kitty | `pkill -USR1 -x kitty` |
| Scripts | ~/.local/bin (shot, session-fade, nightlight, bar-*, wall-*) | n/a |

## Colours
Neutrals are static Catppuccin Mocha literals (base #1e1e2e, mantle #181825,
surface0 #313244, text #cdd6f4). Accents come from the wallpaper:
`wall-set <image>` runs matugen (~/.config/matugen/config.toml), which renders
templates/ into accents files per app and runs each app's reload hook.
Text colours stay Mocha text for legibility. To restyle: edit the template or
the app's static CSS, never a generated accents file.

## Workflow
1. Read the relevant files first; check Hyprland keys in hl.meta.lua.
2. Propose the smallest change; name the file and the reload command.
3. After it works: `chezmoi diff`, `chezmoi apply`, verify, then suggest a
   commit (`chezmoi git -- commit -am "..."`) and a Timeshift snapshot.

## Gotchas on this machine
- AQ_DRM_DEVICES uses /dev/dri/intel-igpu and /dev/dri/nvidia-dgpu (udev
  symlinks); card numbers swap between boots.
- DP-4 (NVIDIA) with HDR/colour management: atomic commits failed and the
  picture went pink; both flags are -1. Root cause not isolated.
- A requested mode must exist in availableModes; DP-4 has 164.84/120/59.95 Hz,
  no 144.
- On battery the dGPU is removed from the PCI bus (gpu-off.service), so
  nvidia-dgpu may not exist.
