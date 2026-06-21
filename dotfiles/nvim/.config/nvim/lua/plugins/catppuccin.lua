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
					NormalFloat = { fg = c.text, bg = c.mantle },
					FloatBorder = { fg = c.surface1, bg = c.mantle },
					FloatTitle = { fg = c.blue, bg = c.mantle, bold = true },
					LspFloatNormal = { fg = c.text, bg = c.mantle },
					LspFloatBorder = { fg = c.surface1, bg = c.mantle },
					Pmenu = { fg = c.text, bg = c.mantle },
					PmenuSel = { fg = c.base, bg = c.blue, bold = true },
					PmenuSbar = { bg = c.surface0 },
					PmenuThumb = { bg = c.surface2 },
					TelescopeNormal = { fg = c.text, bg = c.mantle },
					TelescopeBorder = { fg = c.surface1, bg = c.mantle },
					TelescopePromptNormal = { fg = c.text, bg = c.crust },
					TelescopePromptBorder = { fg = c.surface1, bg = c.crust },
					TelescopePromptTitle = { fg = c.crust, bg = c.blue, bold = true },
					TelescopeResultsNormal = { fg = c.text, bg = c.mantle },
					TelescopeResultsBorder = { fg = c.surface1, bg = c.mantle },
					TelescopeResultsTitle = { fg = c.mantle, bg = c.mantle },
					TelescopePreviewNormal = { fg = c.text, bg = c.mantle },
					TelescopePreviewBorder = { fg = c.surface1, bg = c.mantle },
					TelescopePreviewTitle = { fg = c.mantle, bg = c.green, bold = true },
					SnacksLazyGitNormal = { fg = c.text, bg = transparent_bg },
					SnacksLazyGitBorder = { fg = c.surface1, bg = transparent_bg },
					SnacksLazyGitTitle = { fg = c.blue, bg = transparent_bg, bold = true },
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
