return function(_)
	for i = 1, 9 do
		hl.workspace_rule({
			workspace = tostring(i),
			monitor = i == 4 and "DP-5" or "DP-4",
			persistent = true,
		})
	end

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
		name = "float-dolphin",
		match = { class = "^(org.kde.dolphin|dolphin)$" },
		float = true,
	})

	hl.window_rule({
		name = "float-1password",
		match = { class = "^1password$" },
		float = true,
	})

	hl.window_rule({
		name = "discord-opacity",
		match = { class = "discord" },
		opacity = "0.94 0.90",
	})
end
