return function(ctx)
    hl.on("hyprland.start", function()
        hl.exec_cmd("nm-applet")
        hl.exec_cmd("waybar")
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd(ctx.apps.startup_script)
    end)
end
