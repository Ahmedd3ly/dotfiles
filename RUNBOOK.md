# Runbook

Manual system steps that live outside chezmoi (and often outside pacman).
Each entry: what, why, the exact commands, and how to check it. /etc changes
are recorded by etckeeper (`sudo etckeeper commit "..."`).

## GRUB theme: Catppuccin Mocha

Why: static Mocha boot menu, matching the desktop neutrals. GRUB is never
recoloured from the wallpaper.

Not tracked by pacman: the theme files are copied into /usr/share by hand, so
a reinstall needs these steps again. Source: https://github.com/catppuccin/grub

1. Find a resolution the firmware offers. Reboot, press `c` at the GRUB menu,
   run `videoinfo`, note the modes, `Esc` back. On this machine (MSI Z16,
   EFI GOP): 2560x1600 (native, preferred, active), 640x480, 800x600,
   1024x768, 1280x1024, 1600x1200, 1920x1080, 1920x1440. The only 16:10 mode
   is native, so use 2560x1600: correct aspect, no mode switch at boot. The
   others would stretch. Trade-off: the theme's Unifont 16 is small there.

2. Install the Mocha flavour only (clone to /tmp, nothing in $HOME):

   ```bash
   git clone --depth 1 https://github.com/catppuccin/grub.git /tmp/catppuccin-grub
   sudo cp -r /tmp/catppuccin-grub/src/catppuccin-mocha-grub-theme /usr/share/grub/themes/
   rm -rf /tmp/catppuccin-grub
   ```

3. Point GRUB at it in /etc/default/grub (edit the existing lines; keep
   GRUB_TERMINAL_OUTPUT commented out or set to gfxterm, or the theme won't
   draw):

   ```
   GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"
   GRUB_GFXMODE=2560x1600,auto
   GRUB_TIMEOUT=2
   ```

   `,auto` falls back to the firmware's choice if the first mode is missing.
   GRUB_TIMEOUT 5 -> 2 saves 3 s per boot (the loader was 9.1 s of a 21.7 s
   boot) and still leaves time to reach the grub-btrfs snapshot submenu.

   Also add `GRUB_DISABLE_BOOTNEXT=true`: since late 2026 grub ships
   /etc/grub.d/31_efi_bootnext, which adds a menu line for every firmware
   boot entry. Here those are GRUB itself (Boot0002) and UEFI OS (Boot0003,
   the --removable fallback copy), both just routes back to this menu.
   Keep the firmware entries (UEFI OS saved the day when the firmware lost
   the GRUB entry); only the menu lines go. Merge any
   /etc/default/grub.pacnew (it carries this setting as the new default).

4. Regenerate and record:

   ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo etckeeper commit "grub: catppuccin mocha theme"
   ```

5. Larger menu font (Unifont 16 is small at 2560x1600). No new package:
   grub-mkfont ships with grub, and the source is the JetBrains Mono Nerd
   Font already installed. Only the glyphs a menu needs are converted
   (Latin, punctuation, box drawing), so the file stays small; the theme's
   stock font.pf2 (full Unifont, 2.4 MB read every boot) is then removed.
   GRUB's own fallback, /boot/grub/fonts/unicode.pf2, is untouched. Layout is
   scaled 1.5x to fit the bigger text; the 32 px icons are left sharp.

   ```bash
   T=/usr/share/grub/themes/catppuccin-mocha-grub-theme
   src=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:style=Regular')
   sudo grub-mkfont -s 24 -r 0x20-0x7e,0xa0-0x17f,0x2500-0x259f -o "$T/jbmono-24.pf2" "$src"
   name=$(grep -a -o 'JetBrains[^[:cntrl:]]*24' "$T/jbmono-24.pf2" | head -n1); echo "font name: $name"
   # Everything below runs only if a name was found (an empty name would
   # blank the theme's fonts).
   [ -n "$name" ] && sudo sed -i \
     -e "s/Unifont Regular 16/$name/g" \
     -e 's/left = 50%-240/left = 50%-360/; s/width = 480/width = 720/' \
     -e 's/item_height = 36/item_height = 54/; s/item_padding = 5/item_padding = 8/' \
     -e 's/item_spacing = 10/item_spacing = 15/; s/item_icon_space = 20/item_icon_space = 24/' \
     -e "s/  align = \"center\"/  align = \"center\"\n  font = \"$name\"/" \
     "$T/theme.txt" \
   && sudo rm "$T/font.pf2" \
   && sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

   Check: `grep loadfont /boot/grub/grub.cfg` lists jbmono-24.pf2 and no
   font.pf2; on reboot the menu text is ~1.5x larger. Undo: re-copy the theme
   folder from step 2 and run grub-mkconfig.

Check: `grep -E "theme|gfxmode" /boot/grub/grub.cfg` shows the theme path and
mode; on reboot the menu is Mocha (dark background, mauve selection), and the
grub-btrfs snapshot submenu is themed too.

Undo: comment out GRUB_THEME, `sudo grub-mkconfig -o /boot/grub/grub.cfg`,
`sudo rm -r /usr/share/grub/themes/catppuccin-mocha-grub-theme`.

## Login: tty1 autologin, hyprlock as the login screen

Why: no username to type and no display manager package; the first screen
after boot is hyprlock (autostart.lua starts it before anything else).
Trade-off, accepted: for the moment between Hyprland starting and hyprlock
drawing, the session is unlocked, and if hyprlock ever failed to start the
desktop would be open. Other ttys still require a normal login. Single-owner
machine, no disk encryption, so physical access already meant file access.

1. Autologin on tty1 only (the username is machine-specific, so this lives
   in /etc, not chezmoi):

   ```bash
   sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
   printf '%s\n' '[Service]' 'ExecStart=' \
     "ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USER %I \$TERM" \
     | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
   sudo systemctl daemon-reload
   sudo etckeeper commit "getty: autologin on tty1"
   ```

   ~/.config/zsh/.zprofile (`uwsm check may-start` → `uwsm start`) then
   starts Hyprland on tty1 as before.

2. hyprlock at session start: already in
   ~/.config/hypr/modules/autostart.lua (chezmoi), first line of
   `hyprland.start`.

Check: `systemctl cat getty@tty1 | grep autologin`; on reboot the boot ends on
the lock screen with no username prompt.

Undo: `sudo rm -r /etc/systemd/system/getty@tty1.service.d && sudo systemctl
daemon-reload`, and remove the hyprlock line from autostart.lua.

## Package audit

Why: pkg_minimal.lst should match what is installed on purpose, so a rebuild
installs exactly this system. Run after adding or removing software.

`spring-clean` (~/.local/bin, monthly or after a big update; `--upgrade`
adds paru -Syu + pacdiff) runs everything below plus the cache, journal,
coredump and Trash cleanup, asking before each destructive step. The
manual commands stay here for when the script isn't available.

```bash
L=~/.local/share/chezmoi/pkg_minimal.lst
awk '!/^[[:space:]]*#/ && NF {print $1}' "$L" | sort -u > /tmp/listed
pacman -Qqe | sort -u > /tmp/inst
echo "listed, not installed:"; comm -23 /tmp/listed /tmp/inst
echo "installed, not listed:"; comm -13 /tmp/listed /tmp/inst
echo "orphans:"; pacman -Qqdt
```

"installed, not listed" also shows the pacstrap set named in the list's
header; anything else either gets a line in the list or gets removed.

Files no package owns (needs pacutils):

```bash
sudo pacreport --unowned-files
```

Expected and fine: generated caches (`*.cache`, `modules.*`, `hwdb.bin`,
`locale-archive`), `/etc/fonts/conf.d` links (made by a pacman hook),
systemd `*.wants/` links, NetworkManager/upower state, etckeeper's
`/etc/.git`, and this machine's own files in `/etc` (tracked by
etckeeper). Look closer at anything in `/usr/lib` or `/var/lib/<app>`
whose app is no longer installed. pacreport's "Unneeded Packages
Installed Explicitly" just means nothing depends on them (leaf
packages), so it is not a removal list.

Housekeeping (pacman-contrib):

```bash
sudo paccache -rk2              # keep the last 2 versions of each package
sudo paccache -ruk0             # drop cached packages that are no longer installed
sudo systemctl enable --now paccache.timer   # weekly, keeps 3 (default)
```

## Apps: Spotify (Spicetify) and Discord (Vesktop), Catppuccin per desktop theme

Why native, not Flatpak: no runtimes or second update channel, and both
theming tools patch the app's own files, which a sandbox gets in the way of.
The flavour follows the desktop theme (theme-pick, SUPER+Shift+T): theme-set
runs `spicetify config color_scheme <flavor> && spicetify apply` (restarts a
running Spotify), and matugen renders Vesktop's quickCss.css import line.
The one-time setup below is still manual.

Spotify: spotify-launcher keeps Spotify in ~/.local/share/spotify-launcher,
user-writable, so Spicetify needs no sudo and no chmod 777 on /opt/spotify.

```bash
paru -S --needed spotify-launcher spicetify-cli
spotify-launcher            # first run: installs Spotify; log in, then quit
spicetify                   # first run: creates ~/.config/spicetify/config-xpui.ini
spicetify config spotify_path "$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
spicetify config prefs_path "$HOME/.config/spotify/prefs"
git clone --depth 1 https://github.com/catppuccin/spicetify.git /tmp/cat-spice
mkdir -p ~/.config/spicetify/Themes && cp -r /tmp/cat-spice/catppuccin ~/.config/spicetify/Themes/ && rm -rf /tmp/cat-spice
spicetify config current_theme catppuccin color_scheme mocha
spicetify config inject_css 1 inject_theme_js 1 replace_colors 1 overwrite_assets 1
spicetify backup apply
```

After Spotify updates itself (spotify-launcher swaps in a fresh copy), the
theme is gone until: `spicetify backup apply`.

Discord: Vesktop has Vencord built in, so Discord updates never undo it.

```bash
paru -S --needed vesktop-bin
```

Then in Vesktop: Settings → Vencord → Themes → tick "Enable Custom CSS".
The QuickCSS file itself (~/.config/vesktop/settings/quickCss.css) is
rendered by matugen from ~/.config/matugen/templates/vesktop-quickcss.css,
importing catppuccin-<flavor>.theme.css; edit the template, not the editor.
Accent variants follow the same pattern (e.g. catppuccin-mocha-pink).

Note: Spicetify and Vencord both modify the official clients, which their
terms of service technically forbid; cosmetic mods are rarely acted on.

## Watchdogs off (no "watchdog did not stop!" at shutdown)

Why: two unrelated "watchdogs", neither useful on a laptop that is attended:
- Hardware watchdog (Intel TCO timer, module iTCO_wdt): a timer in the
  chipset that resets the machine if nothing pets it, meant for unattended
  servers. systemd arms it during reboot (RebootWatchdogSec), and at
  shutdown the kernel prints "watchdog: watchdog0: watchdog did not stop!"
  because the driver is closed without being disarmed. Harmless, just noise.
- Kernel soft-lockup / NMI watchdog: periodic checks for stuck CPUs; the
  NMI one keeps a perf counter busy and costs a little power.
Neither relates to daily use here; disabling both is the Arch wiki's
"Improving performance" advice for desktops/laptops.

```bash
printf '%s\n' '# Hardware watchdog: not needed on an attended laptop (see RUNBOOK.md)' \
  'blacklist iTCO_wdt' 'blacklist iTCO_vendor_support' \
  | sudo tee /etc/modprobe.d/nowatchdog.conf
# kernel parameters: add to GRUB_CMDLINE_LINUX_DEFAULT
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nowatchdog nmi_watchdog=0"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo etckeeper commit "watchdogs off: blacklist iTCO_wdt, nowatchdog nmi_watchdog=0"
```

Check after reboot: `lsmod | grep -i tco` prints nothing; `cat
/proc/sys/kernel/watchdog /proc/sys/kernel/nmi_watchdog` prints 0 and 0;
no "did not stop" in `journalctl -b -1 | grep -i watchdog` after a reboot.
Undo: delete /etc/modprobe.d/nowatchdog.conf, remove the two parameters.

## AI agent CLI (Claude Code)

Why: the agent behind `ai` (SUPER+Shift+Return, `ask`, crash diagnosis).
Native installer, not pacman: it's the vendor's recommended method, needs no
Node.js, and updates itself in the background. Files: launcher
~/.local/bin/claude, versions in ~/.local/share/claude. Its settings, login and
history go to ~/.config/claude because CLAUDE_CONFIG_DIR is set (zsh 10-env and
`ai`); set it before the first run or it creates ~/.claude and ~/.claude.json.
None of that state is in the dotfiles (.chezmoiignore).

Open a new terminal first (so zsh reads 10-env), then run these one at a
time; don't paste the block (an `exec zsh` or a login prompt swallows the rest):

```bash
echo "$CLAUDE_CONFIG_DIR"                # /home/<you>/.config/claude
curl -fsSL https://claude.ai/install.sh | bash
claude --version                         # "<version> (Claude Code)"
ai                                       # first run: log in through the browser
ls -A ~ | grep -i claude                 # nothing: no ~/.claude, no ~/.claude.json
```

Account sync off: settings.json is seeded (once) with disableClaudeAiConnectors,
syncClaudeAiPlugins=false and syncClaudeAiSkills=false. Logging in otherwise
imports the claude.ai account's connectors and plugins as MCP servers, and its
skills into skills/synced, which is the shared ~/.config/agents/skills.
Turn one back on in ~/.config/claude/settings.json when you actually want it.

Safety: never start it with permissions skipped. System changes: plan mode
first (Shift+Tab), Timeshift snapshot, then review `chezmoi diff` / `sudo
etckeeper vcs diff`. Engine switch: ~/.config/ai/agent + a branch in ~/.local/bin/ai.
Uninstall: `rm ~/.local/bin/claude; rm -rf ~/.local/share/claude ~/.config/claude`
(the last one deletes login and history; the tracked links come back on apply).

## Gaming: Steam, Heroic, and the game launcher (SUPER+Shift+G)

Why: one picker for every game on the machine. `gamelauncher` lists Steam
games (every library, including /games/SteamLibrary), Heroic's installed
Epic/GOG/Amazon/sideloaded games, and portable games in /games, as a cover
grid inside a handheld frame. Code: ~/.local/bin/gamelauncher (entry) and
~/.local/lib/gamelauncher/{steam,heroic,manual}.py, standard library only.
[multilib] is already enabled (ARCH_INSTALL.md, Phase 4).

Packages: the Gaming section of pkg_minimal.lst (steam, the lib32 drivers,
heroic-games-launcher-bin). Not installed on purpose: gamemode, mangohud,
gamescope (the list says why).

```bash
paru -S --needed steam lib32-mesa lib32-vulkan-intel lib32-nvidia-utils heroic-games-launcher-bin
```

1. Steam: start it, Settings > Storage > add /games/SteamLibrary.
2. Heroic: log in to the stores, then Settings > General: default install
   path /games/Heroic and Wine prefixes /games/Heroic/Prefixes. Both names are
   skipped by the /games scanner, so Heroic games aren't listed twice.
   Theme (desktop theme + wallpaper accent): Settings > General > Custom
   Themes Path = `~/.config/heroic/themes`, then Theme = matugen. Or, with
   Heroic closed:
   ```bash
   h=~/.config/heroic
   jq --arg p "$h/themes" '.defaultSettings.customThemesPath = $p' $h/config.json > $h/c.tmp && mv $h/c.tmp $h/config.json
   jq '.theme = "matugen.css"' $h/store/config.json > $h/s.tmp && mv $h/s.tmp $h/store/config.json
   ```
   matugen renders the file on every wall-set; Heroic reads it when it starts.
3. Frame image (optional; GPL-3, from HyDE, so it isn't committed here).
   Without it the picker is a plain glass panel:
   ```bash
   curl -fsSL --create-dirs -o ~/.local/share/gamelauncher/steamdeck_holographic.png \
     https://raw.githubusercontent.com/HyDE-Project/HyDE/master/Configs/.local/share/hyde/rofi/assets/steamdeck_holographic.png
   ```
4. Portable games: one folder each under /games. A run_game.sh/start.sh at
   the top or an executable in bin/ is found automatically. Anything else
   gets a `.gamelauncher.json` in its folder:
   ```json
   { "name": "SuperTuxKart", "exec": "bin/supertuxkart", "icon": "data/stk_256.png" }
   { "run": "WINEPREFIX=/games/Prefixes/foo wine Foo.exe" }
   { "skip": true }
   ```

Check: `gamelauncher --list` prints one line per game with its backend and
launch target (`icon=no` means no cover was cached yet: open the game's page
once in Steam or Heroic). Each backend also runs alone for debugging:
`python3 ~/.local/lib/gamelauncher/heroic.py`.
