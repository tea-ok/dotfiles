return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  opts = {},
  init = function()
    vim.g.nvim_surround_config = {
      keymaps = {
        visual = "S",
        visual_line = "gS",
      },
    }
  end,
}
