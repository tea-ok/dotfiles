return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    local group = vim.api.nvim_create_augroup("snacks_solid_floats", { clear = true })

    local function apply()
      vim.api.nvim_set_hl(0, "SnacksSolidFloat", { bg = "#282828" })
      vim.api.nvim_set_hl(0, "SnacksSolidBorder", { fg = "#d79921", bg = "#282828" })
    end

    apply()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = apply,
    })
  end,
  opts = {
    dashboard = {
      enabled = true,
    },
    terminal = {
      win = { position = "float" },
    },
    lazygit = {},
    styles = {
      terminal = {
        backdrop = 60,
        border = "rounded",
        wo = {
          winblend = 0,
          winhighlight = {
            Normal = "SnacksSolidFloat",
            NormalNC = "SnacksSolidFloat",
            FloatBorder = "SnacksSolidBorder",
          },
        },
        keys = {
          hide_terminal = { "<C-q>", "hide", mode = "t", desc = "Hide terminal" },
        },
      },
      lazygit = {
        backdrop = 60,
        border = "rounded",
        wo = {
          winblend = 0,
          winhighlight = {
            Normal = "SnacksSolidFloat",
            NormalNC = "SnacksSolidFloat",
            FloatBorder = "SnacksSolidBorder",
          },
        },
      },
    },
  },
}
