-- █ █▄░█ █▀█ █░█ ▀█▀
-- █ █░▀█ █▀▀ █▄█ ░█░
--
-- Why: keyboard layout, pointer and touchpad behaviour in one place.

hl.config({
    input = {
        -- English + Arabic; SUPER+Space cycles (binds.lua). The variant list
        -- needs one entry per layout, hence the comma.
        kb_layout  = "us,ara",
        kb_variant = ",",
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
