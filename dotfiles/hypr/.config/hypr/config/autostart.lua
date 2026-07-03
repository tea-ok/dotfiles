return function(ctx)
    hl.on("hyprland.start", function()
        hl.exec_cmd("pidof hypridle >/dev/null 2>&1 || hypridle")
        hl.exec_cmd("pidof hyprpaper >/dev/null 2>&1 || hyprpaper")
        hl.exec_cmd(ctx.apps.startup_script)
    end)
end
