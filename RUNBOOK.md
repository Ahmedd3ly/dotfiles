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
