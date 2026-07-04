return function(ctx)
    hl.on("hyprland.start", function()
        hl.exec_cmd(ctx.apps.password_manager, { workspace = 4 })
    end)
end
