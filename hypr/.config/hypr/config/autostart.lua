return function(ctx)
    hl.on("hyprland.start", function()
        hl.exec_cmd("pidof hypridle >/dev/null 2>&1 || hypridle")
        hl.exec_cmd("pidof swaync >/dev/null 2>&1 || swaync")
        hl.exec_cmd("waybar")
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd(ctx.apps.startup_script)
    end)
end
