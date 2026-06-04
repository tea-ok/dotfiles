return function(ctx)
    local apps = ctx.apps
    local main_mod = "SUPER"

    hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(apps.terminal))
    hl.bind(main_mod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }))
    hl.bind(main_mod .. " + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }))
    hl.bind(main_mod .. " + SHIFT + C", hl.dsp.window.close())
    hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
    hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(apps.file_manager))
    hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
    hl.bind(main_mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(apps.menu))
    hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
    hl.bind(main_mod .. " + J", hl.dsp.layout("togglesplit"))

    hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }))
    hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
    hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

    for i = 1, 10 do
        local key = i % 10
        hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
    hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
    hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
end
