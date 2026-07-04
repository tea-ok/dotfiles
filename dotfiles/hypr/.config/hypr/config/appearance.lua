return function(ctx)
	local c = ctx.colors

	hl.config({
		general = {
			gaps_in = 5,
			gaps_out = 20,
			border_size = 2,
			col = {
				active_border = {
					colors = {
						"rgba(" .. c.mauveAlpha .. "ee)",
						"rgba(" .. c.blueAlpha .. "ee)",
					},
					angle = 45,
				},
				inactive_border = "rgba(" .. c.overlay0Alpha .. "aa)",
			},
			resize_on_border = false,
			allow_tearing = false,
			layout = "dwindle",
		},
		decoration = {
			rounding = 10,
			rounding_power = 2,
			active_opacity = 1.0,
			inactive_opacity = 1.0,
			shadow = {
				enabled = true,
				range = 4,
				render_power = 3,
				color = "rgba(" .. c.crustAlpha .. "ee)",
			},
			blur = {
				enabled = true,
				size = 3,
				passes = 1,
				vibrancy = 0.1696,
				ignore_opacity = false,
				xray = true,
			},
		},
		dwindle = {
			preserve_split = true,
		},
		master = {
			new_status = "master",
		},
		scrolling = {
			fullscreen_on_one_column = true,
		},
		misc = {
			force_default_wallpaper = 0,
			disable_hyprland_logo = true,
		},
	})
end
