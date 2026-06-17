return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		lazygit = { enabled = true },
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
		picker = {
			enabled = true,
		},
		zen = {
			toggles = { dim = true },
			win = { width = 0.6 },
		},
	},
	keys = {
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Zen Mode",
		},
	},
}
