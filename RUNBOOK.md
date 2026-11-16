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
   run `videoinfo`, note the modes, `Esc` back. On this machine:
   **(fill in after checking)**. Prefer a 16:10 mode below native (e.g.
   1920x1200): the theme's Unifont 16 is tiny at 2560x1600 and the full
   panel resolution can be slow or missing in GOP.

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
   GRUB_GFXMODE=1920x1200,auto
   ```

   `,auto` falls back to the firmware's choice if the first mode is missing.

4. Regenerate and record:

   ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo etckeeper commit "grub: catppuccin mocha theme"
   ```

Check: `grep -E "theme|gfxmode" /boot/grub/grub.cfg` shows the theme path and
mode; on reboot the menu is Mocha (dark background, mauve selection), and the
grub-btrfs snapshot submenu is themed too.

Undo: comment out GRUB_THEME, `sudo grub-mkconfig -o /boot/grub/grub.cfg`,
`sudo rm -r /usr/share/grub/themes/catppuccin-mocha-grub-theme`.
