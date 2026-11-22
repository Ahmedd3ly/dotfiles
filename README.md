<div align="center">

<a href="#gallery">
  <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=34&duration=3200&pause=900&color=CBA6F7&center=true&vCenter=true&width=820&height=64&lines=Anubis;Ahmed+Khatib's+Arch+%2B+Hyprland;One+wallpaper.+One+palette.+Everywhere.;Every+line+understood." alt="Anubis: Ahmed Khatib's Arch + Hyprland dotfiles">
</a>

<p>
  <img src="https://img.shields.io/badge/Arch_Linux-1e1e2e?style=for-the-badge&logo=archlinux&logoColor=89b4fa" alt="Arch Linux">
  <img src="https://img.shields.io/badge/Hyprland_0.57-1e1e2e?style=for-the-badge&logo=lua&logoColor=cba6f7&label=&labelColor=1e1e2e" alt="Hyprland 0.57, Lua config">
  <img src="https://img.shields.io/badge/Catppuccin_Mocha-1e1e2e?style=for-the-badge&logoColor=f5c2e7" alt="Catppuccin Mocha">
  <img src="https://img.shields.io/badge/chezmoi-1e1e2e?style=for-the-badge&logo=git&logoColor=a6e3a1" alt="chezmoi">
</p>
<p>
  <img src="https://img.shields.io/badge/Maintained-Daily_driver-a6e3a1?style=flat-square&labelColor=313244" alt="Maintained: daily driver">
  <img src="https://img.shields.io/badge/Idle_on_battery-17.5_W-89b4fa?style=flat-square&labelColor=313244" alt="Idle on battery: 17.5 W">
  <img src="https://img.shields.io/badge/AUR_packages-5-f9e2af?style=flat-square&labelColor=313244" alt="AUR packages: 5">
  <img src="https://img.shields.io/badge/AI-engine--agnostic-f5c2e7?style=flat-square&labelColor=313244" alt="AI: engine-agnostic">
</p>

<img src=".github/assets/desktop.png" alt="The Anubis desktop" width="100%">

</div>

<br>

> **My daily driver**, built by hand on a bare Arch install. I started from HyDE's look,
> threw away everything I didn't understand, and rebuilt the rest one layer at a time.
> No installer, no theme engine, no background daemons: ~20 short scripts and a palette
> that follows the wallpaper.

## Gallery

<table>
  <tr>
    <td width="50%"><img src=".github/assets/lockscreen.png" alt="Lock screen"><p align="center"><b>Lock = login.</b> tty1 autologin hands off to hyprlock. Clock set in <i>KhatibScript</i>, my own font.</p></td>
    <td width="50%"><img src=".github/assets/theming.gif" alt="Wallpaper recolours the desktop"><p align="center"><b>Wallpaper in, palette out.</b> One pick recolours the bar, menus, terminal, borders, lock screen and GTK.</p></td>
  </tr>
  <tr>
    <td width="50%"><img src=".github/assets/menus.png" alt="Rofi menus"><p align="center"><b>One menu system.</b> Launcher, wallpapers, emoji, clipboard, keybind cheat sheet, power tiles.</p></td>
    <td width="50%"><img src=".github/assets/crash-diagnose.gif" alt="Crash diagnosis"><p align="center"><b>Crash → click → diagnosis.</b> An AI agent reads a facts report in read-only mode.</p></td>
  </tr>
  <tr>
    <td colspan="2"><img src=".github/assets/terminal.png" alt="Terminal"><p align="center"><b>Terminal.</b> kitty, modular zsh, starship and fastfetch.</p></td>
  </tr>
</table>

<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=22&duration=2600&pause=1200&color=89B4FA&center=true&vCenter=true&width=600&height=40&lines=What's+inside;Small.+Legible.+Recoverable." alt="What's inside">
</div>

| | |
|---|---|
| 🎨 **Wallpaper-driven theme** | SUPER+Shift+T picks a theme (Catppuccin Mocha; room for more dark themes) for the neutrals; matugen derives the accents from that theme's wallpapers, so text is always readable. |
| 🪟 **Polished, not heavy** | Blur, animations, fades to black on logout/reboot, a themed GRUB. All of it is cheap config. |
| 🤖 **AI, my way** | `SUPER+Shift+Return` opens an agent. Crashes offer a one-click diagnosis. Swapping the engine is one line. |
| 🔋 **Laptop-aware** | Idle power on battery cut from 36.8 W to 17.5 W. The NVIDIA GPU is unplugged from the bus on battery. Game mode on one key. |
| 🛟 **Safe to break** | Btrfs snapshots bootable from GRUB, `/etc` in etckeeper, every dotfile change previewed with `chezmoi diff`. |
| 📜 **Every line explained** | Each file starts with a banner and a `Why:` line. One concern per file. Nothing in `$HOME`'s root. |

## Get it

| Step | Where |
|---|---|
| 1. Bare metal → Arch with Btrfs, zram and Timeshift | [**ARCH_INSTALL.md**](ARCH_INSTALL.md) |
| 2. Packages and dotfiles | ARCH_INSTALL.md, Phases 5 and 7 (`pkg_minimal.lst`, `chezmoi apply`) |
| 3. GRUB theme, autologin, AI agent, app themes | [**RUNBOOK.md**](RUNBOOK.md) |

> Made for one laptop (MSI Creator Z16, Intel + NVIDIA) and one monitor (Samsung G5).
> Borrow freely, but expect to adapt `monitors.lua` and the GPU setup.

<details>
<summary><b>⌨️ The keys I use most</b></summary>
<br>

`SUPER+`` ` `` shows every binding, searchable, built live from Hyprland.

| Keys | Action | Keys | Action |
|---|---|---|---|
| `SUPER+Return` | Terminal | `SUPER+A` | Launcher |
| `SUPER+Shift+Return` | AI agent | `SUPER+Shift+W` | Wallpaper + recolour |
| `SUPER+V` | Clipboard history | `SUPER+Shift+S` | Screenshot (to clipboard) |
| `SUPER+L` | Lock | `Ctrl+Alt+Del` | Power tiles |

</details>

<details>
<summary><b>🧱 The stack</b></summary>
<br>

Hyprland (Lua config) · uwsm · hyprlock · hypridle · hyprsunset · waybar · rofi · mako ·
awww · matugen · kitty · zsh · starship · fastfetch · Thunar · Firefox · chezmoi ·
etckeeper · Timeshift · Claude Code (behind an engine-neutral `ai` wrapper).
Every package and why it's here: [`pkg_minimal.lst`](pkg_minimal.lst).

</details>

<details>
<summary><b>⚖️ Honest notes</b></summary>
<br>

**Good at:** reproducibility (one repo, reviewed diffs), a small readable surface,
contrast-safe theming, measured power tuning, cheap recovery.

**Not yet:**
- Hardware-specific: monitor modes, the hybrid GPU and the power tweaks assume this laptop.
- HDR is forced off on the NVIDIA-wired monitor (it went pink); the root cause isn't isolated.
- Battery stops improving at package C-state PC3; cause not found.
- Hyprland's Lua API is young, so updates get a `hyprctl configerrors` check.
- Snapshots live on the same disk, and wallpapers aren't in the repo.
- `$HOME` is clean except for what upstream hard-codes: Steam's `.steam`,
  `.steampath`, `.steampid`, and `.pki` from the old Chromium inside Steam and
  Heroic. A fake-HOME wrapper could hide them, but would move native games' saves.
- The full rebuild hasn't been rehearsed in a VM yet.

</details>

<details>
<summary><b>🗺️ Next</b></summary>
<br>

- [ ] Rebuild test in a VM, then fix whatever the docs got wrong
- [ ] Bootstrap script for the dotfiles steps, with a dry run
- [ ] Off-machine backups
- [ ] CI: shellcheck, Lua lint, JSON lint
- [ ] Real screenshots and GIFs in place of the placeholders above

</details>

<br>

<div align="center">

<sub>Built and maintained by <a href="https://github.com/Ahmedd3ly"><b>Ahmed Khatib</b></a> on <b>Anubis</b> 🐺 ·
look inspired by <a href="https://github.com/HyDE-Project/HyDE">HyDE</a> ·
colours by <a href="https://catppuccin.com">Catppuccin</a> ·
crash-to-AI idea from <a href="https://github.com/basecamp/omarchy">Omarchy</a></sub>

</div>
