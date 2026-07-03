return function(_)
    hl.config({
        input = {
            kb_layout = "us,fi",
            kb_options = "grp:alt_shift_toggle",
            follow_mouse = 1,
            sensitivity = 0,
            touchpad = {
                tap_to_click = true,
                natural_scroll = true,
            },
        },
    })

    hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
    })
end
