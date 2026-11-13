-- █░█ █▄█ █▄▄ █▀█ █ █▀▄ ▄▄ █▀▀ █▀█ █░█
-- █▀█ ░█░ █▄█ █▀▄ █ █▄▀ ░░ █▄█ █▀▀ █▄█
--
-- Why: DP-4 is wired to the NVIDIA GPU. With HDR and colour management
-- active, the driver sent an HDR infoframe while Hyprland rendered SDR,
-- atomic commits failed with "Invalid argument" and the picture went pink.
-- Fix = this global switch + supports_hdr/supports_wide_color = 0 on DP-4
-- (in monitors.lua). Which of the two actually matters is not isolated yet.
--
-- GPU selection (AQ_DRM_DEVICES) is NOT here: Hyprland reads it before this
-- file runs, so it lives in ~/.config/uwsm/env-hyprland.
-- Hand-owned now; first-launch.sh must no longer generate this file.

hl.config({ render = { cm_enabled = false } })
