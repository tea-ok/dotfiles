return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	opts = {
		flavour = "frappe",
		transparent_background = true,
		integrations = {
			blink_cmp = true,
			nvimtree = true,
			gitsigns = true,
			telescope = { enabled = true },
			treesitter = true,
			mason = true,
		},
		highlight_overrides = {
			frappe = function(c)
				local transparent_bg = vim.g.neovide and c.base or "NONE"

				return {
					Normal = { bg = transparent_bg },
					NormalNC = { bg = transparent_bg },
					NormalFloat = { bg = transparent_bg },
					FloatBorder = { bg = transparent_bg },
					SignColumn = { bg = transparent_bg },
					EndOfBuffer = { bg = transparent_bg },
					StatusLine = { fg = c.text, bg = c.mantle },
					StatusLineNC = { fg = c.overlay0, bg = c.mantle },
					StlBase = { fg = c.text, bg = c.mantle },
					StlRight = { fg = c.text, bg = c.mantle },

					StlModeN = { fg = c.base, bg = c.blue, bold = true },
					StlModeI = { fg = c.base, bg = c.green, bold = true },
					StlModeV = { fg = c.base, bg = c.mauve, bold = true },
					StlModeR = { fg = c.base, bg = c.red, bold = true },
					StlModeC = { fg = c.base, bg = c.yellow, bold = true },
					StlModeT = { fg = c.base, bg = c.teal, bold = true },

					StlDiagError = { fg = c.red, bg = c.mantle },
					StlDiagWarn = { fg = c.yellow, bg = c.mantle },
					StlDiagInfo = { fg = c.sky, bg = c.mantle },
				}
			end,
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
