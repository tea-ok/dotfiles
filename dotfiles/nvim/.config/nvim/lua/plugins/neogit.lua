return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
	},
	cmd = "Neogit",
	keys = {
		{
			"<leader>gg",
			function()
				require("neogit").open()
			end,
			desc = "Neogit",
		},
		{
			"<leader>gd",
			function()
				if next(require("diffview.lib").views) ~= nil then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "Diffview toggle",
		},
		{
			"<leader>gh",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "Diffview file history",
		},
	},
	config = true,
}
