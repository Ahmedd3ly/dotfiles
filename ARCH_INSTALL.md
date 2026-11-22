# Anubis: Arch Install Runbook

*MSI Creator Z16 · UEFI · Btrfs + zram + Timeshift + Hyprland · Windows removed*

From a blank disk to a booting Arch system with snapshots, then the dotfiles on top.
What comes after (GRUB theme, autologin, watchdogs, AI agent, app themes) is in
[RUNBOOK.md](RUNBOOK.md); the showcase is in [README.md](README.md).

## Decisions

- **Wipe the whole disk.** Windows is gone, so nothing is shared. Back up anything you need first (including MSI's recovery partition if you care about it).
- **Three partitions:** a 1 GiB ESP mounted at `/efi`, the Btrfs root (whatever is left), and a 500 GB ext4 partition for games at /games, outside the snapshots.
- **`/boot` lives inside `@`, not on the ESP.** In your notes the ESP was `/boot`, so kernels sat outside the snapshots. A Timeshift rollback would then pair old system files with a newer kernel and mismatched modules. With `/boot` inside `@`, kernel and initramfs roll back with the system.
- **Subvolumes:** `@` (/), `@home`, `@log`, `@cache` (/var/cache, includes the pacman cache), `@docker` (/var/lib/docker), `@libvirt` (VM images, no copy-on-write). Only `@` (and `@home` if you enable it) is snapshotted, so rollbacks don't erase logs or balloon with Docker layers and VM disks.
- **No `@snapshots`.** Timeshift's Btrfs mode keeps its own snapshots on the top-level volume.
- **Timeshift, not Snapper.** You planned it, and restoring from a GRUB snapshot entry is simple. Snapper's pacman hooks are nicer, but its rollback on a flat layout is fiddly. I dropped `timeshift-autosnap` (AUR, poorly maintained) for a small `sysup` function that snapshots before upgrading.
- **zram only**, no swap partition, so no hibernation.
- **One kernel (`linux`)**, no LTS. Snapshots are your fallback.
- **No display manager.** Log in at the tty; `uwsm` starts Hyprland.
- **No disk encryption.** If you want LUKS on a laptop, decide before Phase 2, because it changes the initramfs hooks and GRUB cmdline.

## Phase 0: Pre-flight

- Back up what you need. Everything on `nvme0n1` is destroyed.
- Secure Boot off in the firmware (GRUB is unsigned). You already run Arch, so this is probably set.
- The dotfiles repo ([github.com/Ahmedd3ly/dotfiles](https://github.com/Ahmedd3ly/dotfiles)) is fetched in Phase 5; it holds `pkg_minimal.lst`.

## Phase 1: Live ISO (network and clock)

```
cat /sys/firmware/efi/fw_platform_size
```

Expect `64`.

```
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect 'Network Name'
ping -c 5 archlinux.org
timedatectl set-ntp true
```

`connect` prompts for the passphrase. `loadkeys us` is already the default.

## Phase 2: Partition, format, subvolumes

```
DISK=/dev/nvme0n1
lsblk -f $DISK
```

Confirm this is the right disk, then:

```
sgdisk --zap-all $DISK
sgdisk -n1:0:+1G -t1:ef00 -c1:ESP $DISK
sgdisk -n2:0:-500G -t2:8300 -c2:archroot $DISK
sgdisk -n3:0:0 -t3:8300 -c3:games $DISK
partprobe $DISK
mkfs.fat -F32 -n ESP ${DISK}p1
mkfs.btrfs -f -L archroot ${DISK}p2
mkfs.ext4 -L games -m 0 ${DISK}p3
```

Create the subvolumes:

```
mount ${DISK}p2 /mnt
for sv in @ @home @log @cache @docker @libvirt; do btrfs subvolume create /mnt/$sv; done
umount /mnt
```

Mount everything, with the same options on every subvolume:

```
o=noatime,compress=zstd:1
mount -o $o,subvol=@ ${DISK}p2 /mnt
mkdir -p /mnt/efi /mnt/home /mnt/games /mnt/var/log /mnt/var/cache /mnt/var/lib/docker /mnt/var/lib/libvirt/images
mount -o $o,subvol=@home ${DISK}p2 /mnt/home
mount -o $o,subvol=@log ${DISK}p2 /mnt/var/log
mount -o $o,subvol=@cache ${DISK}p2 /mnt/var/cache
mount -o $o,subvol=@docker ${DISK}p2 /mnt/var/lib/docker
mount -o $o,subvol=@libvirt ${DISK}p2 /mnt/var/lib/libvirt/images
mount ${DISK}p1 /mnt/efi
mount ${DISK}p3 /mnt/games
chattr +C /mnt/var/lib/libvirt/images
findmnt -R /mnt
```

`chattr +C` makes future VM disk images no-CoW. It only works while the directory is empty.

## Phase 3: Install the base, generate fstab

```
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode sof-firmware btrfs-progs grub grub-btrfs inotify-tools efibootmgr networkmanager sudo reflector neovim zsh git man-db man-pages pacman-contrib zram-generator cronie
genfstab -U /mnt >> /mnt/etc/fstab
sed -i -e 's/subvolid=[0-9]*,//' -e 's/fmask=0022,dmask=0022/fmask=0077,dmask=0077/' /mnt/etc/fstab
cat /mnt/etc/fstab
```

Check: no `subvolid=` left, six Btrfs lines with identical options, and `/efi` as vfat, and /games as ext4. `linux-headers` is left out; add it only if you ever use DKMS. NVIDIA comes later from `pkg_minimal.lst`.

## Phase 4: Configure inside the chroot

```
arch-chroot /mnt
```

Time, locale, identity:

```
ln -sf /usr/share/zoneinfo/Africa/Cairo /etc/localtime
hwclock --systohc
sed -i -e 's/^#en_US.UTF-8/en_US.UTF-8/' -e 's/^#ar_EG.UTF-8/ar_EG.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf
echo 'Anubis' > /etc/hostname
echo 'EDITOR=nvim' >> /etc/environment
echo 'VISUAL=nvim' >> /etc/environment
```

Pacman (color, parallel downloads, multilib for Steam) and mirrors:

```
sed -i -e 's/^#Color/Color/' -e 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/^#[[]multilib[]]/,+1 s/^#//' /etc/pacman.conf
cat > /etc/xdg/reflector/reflector.conf <<'EOF'
--save /etc/pacman.d/mirrorlist
--protocol https
--latest 20
--sort rate
EOF
reflector @/etc/xdg/reflector/reflector.conf
pacman -Syu
```

Users and sudo:

```
passwd
useradd -m -G wheel -s /bin/zsh ahmedkhatib
passwd ahmedkhatib
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
visudo -c
```

Initramfs. First compare with the stock hooks (`grep ^HOOKS /etc/mkinitcpio.conf`). The drop-in below keeps them, removes `fsck`, and appends the snapshot overlay hook. If your stock line differs, mirror it.

```
mkdir -p /etc/mkinitcpio.conf.d
cat > /etc/mkinitcpio.conf.d/10-custom.conf <<'EOF'
MODULES=(i915)
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems grub-btrfs-overlayfs)
EOF
mkinitcpio -P
```

Bootloader:

```
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-install --target=x86_64-efi --efi-directory=/efi --removable
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 zswap.enabled=0 nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
grep -m1 rootflags /boot/grub/grub.cfg
efibootmgr -v
ls /efi/EFI/GRUB /efi/EFI/BOOT
```

Before you reboot, check all three: the `grep` shows `rootflags=subvol=@`, `efibootmgr -v` lists a `GRUB` entry, and both `grubx64.efi` (in `/efi/EFI/GRUB`) and `BOOTX64.EFI` (in `/efi/EFI/BOOT`) exist.

GRUB is installed twice on purpose. Some firmware, this MSI included, silently drops the boot entry that the first command creates, and the machine then goes straight to firmware setup. The `--removable` copy sits at the fallback path every UEFI firmware checks on its own, so boot works either way. Afterwards the firmware may list both a `GRUB` entry and a `UEFI OS` entry. Both start the same GRUB, so leave them alone.

zram and VM tuning (the generator creates the device at boot; nothing to start):

```
mkdir -p /etc/systemd/zram-generator.conf.d
cat > /etc/systemd/zram-generator.conf.d/zram.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF
cat > /etc/sysctl.d/99-zram.conf <<'EOF'
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF
```

Services:

```
systemctl enable NetworkManager systemd-timesyncd reflector.timer cronie 'btrfs-scrub@-.timer'
```

Finish:

```
exit
umount -R /mnt
reboot
```

Pull the USB, boot Arch from GRUB, and log in as `ahmedkhatib`.

## Phase 5: First boot

```
nmcli --ask device wifi connect 'Network Name'
ping -c 5 archlinux.org
efibootmgr
```

If `efibootmgr` still lists a stale "Windows Boot Manager", remove it with `sudo efibootmgr -b 0000 -B` (use the number shown).

Paru (the binary package avoids pulling in a Rust toolchain):

```
touch ~/.zshrc
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si && cd .. && rm -rf paru-bin
```

Fetch the dotfiles (clone only; nothing is applied until Phase 7), then install every
package from `pkg_minimal.lst`:

```
sudo pacman -S --needed chezmoi
chezmoi init https://github.com/Ahmedd3ly/dotfiles.git
awk '!/^[[:space:]]*#/ && NF {print $1}' ~/.local/share/chezmoi/pkg_minimal.lst | paru -S --needed -
```

Read the inline comments in the list: a few packages need a follow-up (`tlp`, `tlp-pd`).

Reboot afterwards so the NVIDIA modules and rebuilt initramfs take effect.

## Phase 6: Snapshots

Make grub-btrfsd watch Timeshift snapshots:

```
sudo mkdir -p /etc/systemd/system/grub-btrfsd.service.d
sudo tee /etc/systemd/system/grub-btrfsd.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/grub-btrfsd --syslog -t
EOF
sudo systemctl daemon-reload
```

First snapshot, then enable the watcher:

```
sudo timeshift --list-devices
sudo timeshift --create --comments 'Anubis Rises'
sudo systemctl enable --now grub-btrfsd
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Once the desktop is up, run `sudo timeshift-launcher` and set a schedule (for example daily 3, weekly 2, everything else 0). Leave "include @home" off: your home is covered by the dotfiles repo and your own backups.

Pre-upgrade snapshot helper: `sysup` (snapshot, then `paru -Syu`) ships with the
dotfiles in `~/.config/zsh/conf.d/40-functions.zsh` and is available after Phase 7.
Snapshots made this way are on-demand, so Timeshift never prunes them. Clean up now and then with `sudo timeshift --list` and `sudo timeshift --delete --snapshot '<name>'`.

Confirm zram:

```
swapon --show
zramctl
```

## Phase 7: Session and dotfiles

Hybrid GPU names (Intel + NVIDIA only): a udev rule gives the GPUs stable names,
because card numbers swap between boots. Run it before applying the dotfiles; the uwsm
env files it also writes are then replaced by the tracked versions, on purpose.

```
~/.local/share/chezmoi/first-launch.sh --primary intel
```

Apply the dotfiles. Review first: `chezmoi diff` shows every file it will write.

```
chezmoi diff | less
chezmoi apply
rm -f ~/.zshrc            # the Phase 5 placeholder; zsh now reads ~/.config/zsh
xdg-user-dirs-update
sudo systemctl enable --now bluetooth
```

`chezmoi apply` also enables the user services (waybar, mako, hypridle, hyprsunset,
ssh-agent, crash notifications). The tracked `~/.config/zsh/.zprofile` starts Hyprland
through uwsm on tty1: log out and back in, and Hyprland starts. Check it with
`hyprctl reload && hyprctl configerrors` (expect no output), then put wallpapers in
`~/Pictures/Wallpapers/<theme id>/` (`catppuccin-mocha`, `catppuccin-latte`; they aren't in
the repo) and pick a theme with `SUPER+Shift+T`, even Mocha: that run sets GTK light/dark
(gsettings) and the first wallpaper. `SUPER+Shift+W` then picks wallpapers within the theme.

Make the games partition yours and create a Steam library folder on it. It is ext4 because Proton prefixes gain nothing from copy-on-write.

```
sudo chown ahmedkhatib:ahmedkhatib /games
mkdir /games/SteamLibrary
```

Then add `/games/SteamLibrary` in Steam under Settings, Storage.

Track `/etc` changes locally (etckeeper comes from `pkg_minimal.lst`). Never push this
repo, since `/etc` can contain secrets.

```
sudo etckeeper init
sudo etckeeper commit 'baseline'
```

Next: [RUNBOOK.md](RUNBOOK.md) for the GRUB theme, autologin, watchdogs and the AI agent.
Take a Timeshift snapshot after each step.

When you set up the Photoshop VM later: `sudo pacman -S qemu-desktop libvirt virt-manager`. The images directory is already no-CoW and out of snapshots.

## Verification checklist

```
findmnt -t btrfs,vfat,ext4
sudo btrfs subvolume list /
swapon --show
systemctl --failed
sudo timeshift --list
```

Expect six Btrfs mounts, one zram swap device, no failed units, and one Timeshift snapshot.

## If boot breaks

Boot the Arch ISO and run:

```
mount -o subvol=@ /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/efi
arch-chroot /mnt
```

From there you can fix configs, rebuild with `mkinitcpio -P`, and re-run `grub-mkconfig -o /boot/grub/grub.cfg`.

**Firmware goes straight to setup, no GRUB entry.** From the same chroot, repeat the two `grub-install` lines from Phase 4, then run `efibootmgr -v`. If there is still no `GRUB` entry, create one by hand:

```
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-install --target=x86_64-efi --efi-directory=/efi --removable
efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader '\EFI\GRUB\grubx64.efi' --label 'GRUB'
```
