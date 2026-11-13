-- █ █▄░█ █▀█ █░█ ▀█▀
-- █ █░▀█ █▀▀ █▄█ ░█░
--
-- Why: keyboard layout, pointer and touchpad behaviour in one place.

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 .. 1.0, 0 = no modification

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- 3-finger horizontal swipe switches workspace.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
