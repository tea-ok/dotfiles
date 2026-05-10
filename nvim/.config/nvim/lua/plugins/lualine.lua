return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/tokyonight.nvim" },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    vim.o.laststatus = vim.g.lualine_laststatus
    return {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        ignore_focus = { "NvimTree" },
      },
    }
  end,
}
