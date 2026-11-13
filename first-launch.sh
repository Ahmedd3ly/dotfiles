#!/usr/bin/env bash
# first-launch.sh: stable GPU names + session env for an Intel + NVIDIA hybrid laptop.
#
# Usage: first-launch.sh [--primary intel|nvidia]
#   intel   (default) The Intel iGPU renders the desktop and the NVIDIA GPU idles until
#           you use prime-run. Best for battery and heat. An external monitor wired to
#           the NVIDIA GPU turns pink unless HDR is forced off on it: set
#           supports_hdr = -1, supports_wide_color = -1 in ~/.config/hypr/modules/monitors.lua
#           (tracked in the dotfiles; this script does not write Hyprland config).
#   nvidia  The NVIDIA GPU renders the desktop. Use it only if the external monitor still
#           glitches with the default, or for a docked gaming session. Costs battery, and
#           the laptop panel is then shown through a GPU-to-GPU copy.
#
# Run as your normal user, from a tty or a terminal. Uses sudo once (udev rule).
# Safe to re-run; files it replaces are backed up once as *.bak.
# AQ_DRM_DEVICES is read when Hyprland starts, so log out and back in afterwards.
set -euo pipefail

info() { printf '\n==> %s\n' "$*"; }
backup() { if [ -f "$1" ] && [ ! -f "$1.bak" ]; then cp "$1" "$1.bak"; fi; }

primary=intel
while [ $# -gt 0 ]; do
    case "$1" in
        --primary)
            [ $# -ge 2 ] || { echo "--primary needs a value: intel or nvidia" >&2; exit 2; }
            primary="$2"; shift 2 ;;
        -h|--help)
            awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print} /^set -e/ {exit}' "$0"; exit 0 ;;
        *) echo "Unknown option: $1 (try --help)" >&2; exit 2 ;;
    esac
done
case "$primary" in
    intel|nvidia) ;;
    *) echo "--primary must be 'intel' or 'nvidia'" >&2; exit 2 ;;
esac

info "Detecting GPUs"
gpus=$(lspci -D | grep -Ei 'vga|3d controller|display controller' || true)
echo "$gpus"
intel=$(grep -i intel <<<"$gpus" | awk '{print $1}' | head -n1 || true)
nvidia=$(grep -i nvidia <<<"$gpus" | awk '{print $1}' | head -n1 || true)
if [ -z "$intel" ] || [ -z "$nvidia" ]; then
    echo "Could not find both an Intel and an NVIDIA GPU. Nothing changed." >&2
    exit 1
fi
echo "Intel: $intel | NVIDIA: $nvidia | primary: $primary"

info "Writing udev rule (stable names: /dev/dri/intel-igpu, /dev/dri/nvidia-dgpu)"
sudo tee /etc/udev/rules.d/10-gpu-names.rules >/dev/null <<EOF
KERNEL=="card*", KERNELS=="$intel", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-igpu"
KERNEL=="card*", KERNELS=="$nvidia", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
EOF
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=drm --action=add
sudo udevadm settle

info "Writing uwsm env files"
mkdir -p "$HOME/.config/uwsm"
backup "$HOME/.config/uwsm/env"
backup "$HOME/.config/uwsm/env-hyprland"

# Variables for every session started through uwsm
cat > "$HOME/.config/uwsm/env" <<'EOF'
# Toolkits on Wayland
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND="wayland,x11,*"
export ELECTRON_OZONE_PLATFORM_HINT=auto

# Cursor
export XCURSOR_SIZE=24
export HYPRCURSOR_SIZE=24

# Video decode on the Intel iGPU (the NVIDIA card is opt-in via prime-run)
export LIBVA_DRIVER_NAME=iHD
EOF

# Hyprland-only variables. AQ_DRM_DEVICES is read when Hyprland starts,
# so it has to live here and not in hyprland.lua. First entry = primary GPU.
if [ "$primary" = intel ]; then
    aq="/dev/dri/intel-igpu:/dev/dri/nvidia-dgpu"
else
    aq="/dev/dri/nvidia-dgpu:/dev/dri/intel-igpu"
fi
cat > "$HOME/.config/uwsm/env-hyprland" <<EOF
# primary=$primary: the first entry renders the desktop.
# Change it by re-running: first-launch.sh --primary intel|nvidia
export AQ_DRM_DEVICES=$aq
EOF

info "External outputs that need HDR forced off in modules/monitors.lua"
for s in /sys/class/drm/card*-*/status; do
    [ -r "$s" ] || continue
    [ "$(cat "$s")" = connected ] || continue
    n=${s#/sys/class/drm/card*-}
    n=${n%/status}
    case "$n" in eDP*) continue ;; esac
    echo "$n: supports_hdr = -1, supports_wide_color = -1"
done

info "Checks"
ls -l /dev/dri/
for name in intel-igpu nvidia-dgpu; do
    if [ -e "/dev/dri/$name" ]; then
        echo "OK: /dev/dri/$name -> $(readlink -f "/dev/dri/$name")"
    else
        echo "MISSING: /dev/dri/$name (Hyprland will not start while AQ_DRM_DEVICES points at it)"
    fi
done
if [ -r /sys/module/nvidia_drm/parameters/modeset ]; then
    echo "nvidia_drm modeset: $(cat /sys/module/nvidia_drm/parameters/modeset) (want Y)"
else
    echo "nvidia_drm is not loaded (expected if the NVIDIA packages are not installed yet, or you have not rebooted)"
fi
grep -o 'nvidia_drm[^ ]*' /proc/cmdline || echo "No nvidia_drm options on the kernel command line"
command -v prime-run >/dev/null || echo "prime-run is missing: install nvidia-prime"

info "Done (primary GPU: $primary). Log out (uwsm stop) and back in, then run: hyprctl reload && hyprctl configerrors"
