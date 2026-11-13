-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Why: one place for outputs and which workspace lives where.
-- Modes must match `hyprctl monitors all` -> availableModes exactly.
-- DP-4's x position must equal eDP-1's logical width (2560 / scale).

hl.monitor({ output = 'eDP-1', mode = '2560x1600@165', position = '0x0', scale = 1.7, bitdepth = 8, cm = 'srgb', vrr = 0 })
hl.monitor({ output = 'DP-4', mode = '2560x1440@165', position = '1600x0', scale = 1, bitdepth = 8, cm = 'srgb', supports_hdr = -1, supports_wide_color = -1, vrr = 0 })

-- Keep workspace 1 on the laptop panel even when the external monitor
-- initialises first (it does when NVIDIA is the primary GPU).
hl.workspace_rule({ workspace = '1', monitor = 'eDP-1', default = true })
