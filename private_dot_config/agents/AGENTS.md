<!--
 ▄▀█ █▀▀ █▀▀ █▄░█ ▀█▀ █▀
 █▀█ █▄█ ██▄ █░▀█ ░█░ ▄█

 Why: standing instructions for any AI coding agent on this machine, written
 once. Each engine gets a link to this file (Claude Code: ~/.config/claude/
 CLAUDE.md). Keep it short: it loads into every session.
-->
# This machine

Ahmed's Arch Linux laptop (MSI Creator Z16): Hyprland 0.55+ with the **Lua**
config, uwsm from tty1 (no display manager), Btrfs + Timeshift + grub-btrfs.
Intel iGPU drives eDP-1; the external Samsung G5 (DP-4) is wired to the RTX 4070.
Ahmed is a software engineer (.NET, Python, Odoo): explain the why, skip basics.

## Safety (always)
- Never run with permissions skipped. Propose system changes in plan mode first.
- Before changing anything outside a project folder: `sudo timeshift --create
  --comments "<what>"`, and say so.
- For anything that can break the session, give the recovery step first
  (Ahmed may be stuck at a tty).
- Never read or upload core files, keys, tokens, ~/.ssh, or ~/.config/claude.

## Where things live
- Dotfiles: chezmoi, source `~/.local/share/chezmoi` (github.com/Ahmedd3ly/dotfiles).
  Edit the **source**, then `chezmoi diff` and `chezmoi apply`; never edit the
  deployed copy. /etc is tracked by etckeeper (local): commit after changes.
- Generated colour files (matugen outputs: accents.*, colors.*) are never
  edited by hand; change ~/.config/matugen/templates instead.
- Packages: `pkg_minimal.lst` in the repo is the curated list. Official repos
  over AUR; every AUR package needs a one-line justification there.
- Manual system steps (GRUB theme, autologin, watchdogs...) are in RUNBOOK.md.

## Conventions
- Hyprland config is Lua only (`hl.*` API), never hyprlang. Check every key and
  dispatcher against `/usr/share/hypr/stubs/hl.meta.lua`; never invent one.
  Verify with `hyprctl reload && hyprctl configerrors`.
- Base monitor/mode values on `hyprctl monitors all` (availableModes).
- XDG-clean: nothing new in $HOME's root (~/.config, ~/.local/share, ~/.cache).
  Known, accepted exceptions (hard-coded upstream, recreated on every start,
  don't "fix" or delete them): ~/.steam, ~/.steampath, ~/.steampid (Steam)
  and ~/.pki (the old Chromium inside Steam and Heroic).
- One concern per file; each file starts with a small block banner and a
  "Why:" line.
- One change at a time, each with a verification command and expected output.

## Style
Direct and concise. Recommendation first, then trade-offs. Say what you have
not verified. If you got something wrong earlier, say so plainly.
