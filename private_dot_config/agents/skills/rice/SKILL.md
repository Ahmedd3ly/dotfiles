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
| Launcher/menus | ~/.config/rofi/*.rasi, scripts rofi-launch, powermenu, wall-pick, theme-pick | next launch |
| Notifications | ~/.config/mako/config | `makoctl reload` |
| Lock | ~/.config/hypr/hyprlock.conf (hyprlang, not Lua: its own format) | next lock |
| Terminal | ~/.config/kitty | `pkill -USR1 -x kitty` |
| Scripts | ~/.local/bin (shot, record, session-fade, nightlight, bar-*, wall-*, theme-*) | n/a |

## Colours
Two layers, both rendered by matugen on every `wall-set <image>`:
- **Neutrals** (base, text, surfaces) come from the current
  *theme*: ~/.config/themes/<id>/palette.json (only catppuccin-mocha;
  light themes were tried and dropped: too bright for Ahmed), passed with
  `--import-json`; templates read `{{ theme.<key> }}` (hex without #) into
  each app's `palette.*` file.
- **Accents** come from the wallpaper (`{{ colors.* }}`, `-m` = theme mode)
  into `accents.*`. Text on an accent uses `on_primary` / `on_tertiary`.
Theme: `theme-pick` (SUPER+Shift+T) -> `theme-set <id>` (state in
~/.local/state/theme, gsettings light/dark) -> `wall-set` with that theme's
last wallpaper. `theme-get [--palette|--walls|<key>]` answers "which theme".
Wallpapers per theme: ~/Pictures/Wallpapers/<id>/ (wall-pick lists only that).
New theme: a palette.json with every key of the Mocha one + a wallpaper folder.
Also per theme: window opacity (palette.json opacity_active/inactive ->
hypr/modules/palette.lua, read by look.lua) and the whole starship.toml
(rendered from templates/starship.toml; its colours are [palettes.theme]).
Always dark Mocha, by choice, in every theme: waybar (theme.css) and hyprlock
(literals); their accent templates use `colors.*.dark` so they match too.
Bar accent block: gradient wallpaper colour -> its 2nd dominant colour when
the hue is within max_hue = 125 deg (wall-set step 2b writes
waybar/accents-end.css; one --dry-run JSON query), else
palettes.secondary._40 (waybar-accents.css). 125 keeps sakura's pink and
accepts blue -> crimson on a few wallpapers; 60 dropped both.
Wallpaper-coloured apps: cava (cava/themes/matugen, primary -> saturated
tertiary left to right; wall-set sends USR2), `palette` (kitty: HyDE-style
round swatches + pill ramps of the wallpaper's matugen palettes, Pillow image
via kitten icat; live via --dry-run, redraws on wallpaper change; showcase)
and Heroic (heroic/themes/matugen.css, read at Heroic's start; RUNBOOK).
Apps that follow the theme via palette.json "flavor" / "nvim_style": Vesktop
(quickCss.css rendered from templates/vesktop-quickcss.css), Spotify (theme-set
runs spicetify config color_scheme + apply; restarts Spotify if running, log
~/.local/state/theme/spicetify.log), Neovim (Tokyo Night style, moon, read at
startup in plugins/colorscheme.lua). Static Mocha still: GRUB.
To restyle: edit the template, the palette.json or the app's static CSS,
never a generated palette.* / accents.* file.

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
