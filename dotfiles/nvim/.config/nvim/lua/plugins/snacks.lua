return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
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
		image = {
			enabled = true,
			doc = {
				enabled = true,
				inline = true,
				float = true,
			},
		},
		zen = {
			toggles = { dim = true },
			win = { width = 0.6 },
		},
	},
	keys = {
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Zen Mode",
		},
		{
			"<leader>mi",
			function()
				Snacks.image.hover()
			end,
			desc = "Markdown image hover",
		},
	},
}
