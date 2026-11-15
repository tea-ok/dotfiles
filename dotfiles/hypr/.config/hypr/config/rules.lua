return function(_)
	for i = 1, 9 do
		hl.workspace_rule({
			workspace = tostring(i),
			monitor = i == 4 and "desc:ASUSTek COMPUTER INC ASUS VG249 0x00000948" or "desc:ASUSTek COMPUTER INC VG27A M2LMQS057496",
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

	-- Generic dialog floating. Hyprland already floats windows that declare a
	-- parent or a fixed size; this catches modals and common dialog titles from
	-- apps that open them as plain toplevels.
	hl.window_rule({
		name = "float-modals",
		match = { modal = true },
		float = true,
	})

	hl.window_rule({
		name = "float-common-dialogs",
		match = {
			title = "^(Open File.*|Open Folder.*|Save File.*|Save As.*|Select a File.*|Choose Files?.*|File Upload.*|Picture-in-Picture|.*[Pp]references|.*[Pp]roperties)$",
		},
		float = true,
	})

	-- Apps whose main window should tile while every other window they open
	-- (settings, friends lists, popups, ...) floats. Key = class regex, value =
	-- title regex of the main window, matched against the title at map time.
	local main_window_tiled = {
		["^steam$"] = "^Steam$",
	}

	for class, main_title in pairs(main_window_tiled) do
		hl.window_rule({
			name = "float-secondary-" .. class:gsub("[^%w]", ""),
			match = { class = class, title = "negative:" .. main_title },
			float = true,
		})
	end

	hl.window_rule({
		name = "discord-opacity",
		match = { class = "discord" },
		opacity = "0.94 0.90",
	})
end
