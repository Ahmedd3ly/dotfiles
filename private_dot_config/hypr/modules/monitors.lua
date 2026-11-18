-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Why: one place for outputs and which workspace lives where.
--
-- Editing rules:
--   - Modes must match `hyprctl monitors all` -> availableModes exactly.
--   - Match the external monitor by description, never by connector name.
--   - Check: hyprctl reload && hyprctl configerrors. If an output is stuck in
--     failing commits after a reload, unplug and replug it to reconfigure.

-- ── Laptop panel · eDP-1 · Intel iGPU ─────────────────────────────────────
-- Matched by name: it's the only eDP connector, so its number never changes.
-- Scale must divide the panel cleanly: 1.666667 -> 1536x960 logical
-- (1.7 was rejected and auto-corrected to 1.6666666).
-- 60.04 Hz on purpose: saves ~1.6 W; the G5 is the gaming screen.
-- vrr = 0: VRR made this panel flicker.
hl.monitor({
	output = "eDP-1",
	mode = "2560x1600@60.04",
	position = "0x0",
	scale = 1.666667,
	bitdepth = 8,
	cm = "srgb",
	vrr = 0,
})

-- ── External · Samsung Odyssey G5 · NVIDIA dGPU ───────────────────────────
-- Matched by description: DRM numbers DP connectors across both GPUs in
-- probe order, which varies per boot (DP-2 on some boots, DP-4 on others).
-- A name-based rule silently missed, HDR fell back to auto and the screen
-- went pink. The serial is in the string, so only this unit matches.
-- Position x = eDP-1's logical width (2560 / 1.666667 = 1536).
-- Mode: no 144 Hz exists; 164.84 is the top one.
-- Pink-screen fix: with supports_hdr / supports_wide_color on auto (0), the
-- driver gets an HDR infoframe while Hyprland renders SDR. Atomic commits
-- then fail ("Invalid argument"), the kernel floods "Infoframe changed" and
-- the picture turns pink. Both at -1 fixes it; which one matters is untested.
-- render.cm_enabled makes no difference. Values: -1 off, 0 auto, 1 force on.
-- vrr = 0: VRR blanked this output.
hl.monitor({
	output = "desc:Samsung Electric Company Odyssey G5 HK2Y200088",
	mode = "2560x1440@164.84",
	position = "1536x0",
	scale = 1,
	bitdepth = 8,
	cm = "srgb",
	supports_hdr = -1,
	supports_wide_color = -1,
	vrr = 0,
})

-- ── Workspace placement ───────────────────────────────────────────────────
-- Keep workspace 1 on the laptop panel even when the external monitor
-- initialises first (it does when NVIDIA is the primary GPU).
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })

-- Workspaces 1-9 always exist, so the bar can show empty ones as rings
-- (waybar's persistent-workspaces needs this). 2-9 have no monitor: they
-- open wherever they're first used.
for i = 2, 7 do
	hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
