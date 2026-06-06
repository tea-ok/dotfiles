return function(_)
    hl.workspace_rule({
        workspace = "4",
        monitor = "DP-5",
        persistent = true,
    })

    hl.window_rule({
        name = "suppress-maximize-events",
        match = { class = ".*" },
        suppress_event = "maximize",
    })

    hl.window_rule({
        name = "fix-xwayland-drags",
        match = {
            class = "^$",
            title = "^$",
            xwayland = true,
            float = true,
            fullscreen = false,
            pin = false,
        },
        no_focus = true,
    })

    hl.window_rule({
        name = "move-hyprland-run",
        match = { class = "hyprland-run" },
        move = "20 monitor_h-120",
        float = true,
    })

    hl.window_rule({
        name = "firefox-opacity",
        match = { class = "firefox" },
        opacity = "0.94 0.90",
    })
end
