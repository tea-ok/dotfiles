return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		style = "storm",
		on_highlights = function(hl, c)
			-- Statusline base
			hl.StatusLine = { fg = c.fg_dark, bg = c.bg_dark }
			hl.StatusLineNC = { fg = c.fg_gutter, bg = c.bg_dark }
			hl.StlBase = { fg = c.fg_dark, bg = c.bg_dark }
			hl.StlRight = { fg = c.fg_dark, bg = c.bg_dark }

			-- Mode blocks
			hl.StlModeN = { fg = c.bg, bg = c.blue, bold = true }
			hl.StlModeI = { fg = c.bg, bg = c.green, bold = true }
			hl.StlModeV = { fg = c.bg, bg = c.purple, bold = true }
			hl.StlModeR = { fg = c.bg, bg = c.red, bold = true }
			hl.StlModeC = { fg = c.bg, bg = c.yellow, bold = true }
			hl.StlModeT = { fg = c.bg, bg = c.cyan, bold = true }

			-- Diagnostic counts
			hl.StlDiagError = { fg = c.error, bg = c.bg_dark }
			hl.StlDiagWarn = { fg = c.warning, bg = c.bg_dark }
			hl.StlDiagInfo = { fg = c.info, bg = c.bg_dark }
		end,
	},
	config = function(_, opts)
		opts.transparent = not vim.g.neovide
		require("tokyonight").setup(opts)
		vim.cmd([[colorscheme tokyonight]])
	end,
}
