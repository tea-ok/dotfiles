return function(_)
	local home = os.getenv("HOME")
	local xcursor_path = os.getenv("XCURSOR_PATH")
		or table.concat({
			"/etc/profiles/per-user/taavi/share/icons",
			home .. "/.icons",
			home .. "/.local/share/icons",
			home .. "/.nix-profile/share/icons",
			home .. "/.local/state/nix/profile/share/icons",
			"/run/current-system/sw/share/icons",
		}, ":")

	hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
	hl.env("XDG_SESSION_DESKTOP", "Hyprland")
	hl.env("XDG_SESSION_TYPE", "wayland")
	hl.env("QT_QPA_PLATFORM", "wayland")
	hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
	hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
	hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")
	hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
	hl.env("XCURSOR_SIZE", "24")
	hl.env("XCURSOR_PATH", xcursor_path)
	hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
	hl.env("HYPRCURSOR_SIZE", "24")
end
