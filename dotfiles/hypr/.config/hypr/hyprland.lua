local config_dir = os.getenv("HOME") .. "/.config/hypr"

local function load(path)
	return dofile(config_dir .. "/" .. path)
end

local ctx = {
	paths = {
		config_dir = config_dir,
	},
	colors = load("themes/catppuccin-frappe.lua"),
	apps = load("lib/apps.lua"),
}

for _, module in ipairs({
	"config/monitors.lua",
	"config/environment.lua",
	"config/autostart.lua",
	"config/appearance.lua",
	"config/input.lua",
	"config/keybinds.lua",
	"config/rules.lua",
	"config/animations.lua",
}) do
	load(module)(ctx)
end
