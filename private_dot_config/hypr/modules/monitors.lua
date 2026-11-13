-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Why: one place for outputs and which workspace lives where.
-- Modes must match `hyprctl monitors all` -> availableModes exactly.
-- DP-4's x position must equal eDP-1's logical width (2560 / scale).
-- Scale must divide the panel cleanly: 1.666667 -> 1536x960 logical
-- (1.7 was rejected and auto-corrected to 1.6666666).

-- Laptop panel (Intel iGPU). vrr = 0: VRR made this panel flicker.
hl.monitor({
    output = 'eDP-1', mode = '2560x1600@165.04', position = '0x0', scale = 1.666667,
    bitdepth = 8, cm = 'srgb', vrr = 0,
})

-- Odyssey G5 (NVIDIA dGPU). No 144 Hz mode exists; 164.84 is the top one.
-- Pink-screen fix: this output is wired to the NVIDIA GPU. With HDR and wide
-- colour both on auto (0), the driver sent an HDR infoframe while Hyprland
-- rendered SDR, atomic commits failed ("Invalid argument") and the picture
-- went pink. Forcing both off (-1) fixes it. Tested Nov 2026: render.cm_enabled
-- (true / false / unset) makes no difference. -1 off, 0 auto, 1 force on.
-- vrr = 0: VRR blanked this output.
hl.monitor({
    output = 'DP-4', mode = '2560x1440@164.84', position = '1536x0', scale = 1,
    bitdepth = 8, cm = 'srgb', supports_hdr = -1, supports_wide_color = -1, vrr = 0,
})

-- Keep workspace 1 on the laptop panel even when the external monitor
-- initialises first (it does when NVIDIA is the primary GPU).
hl.workspace_rule({ workspace = '1', monitor = 'eDP-1', default = true })
