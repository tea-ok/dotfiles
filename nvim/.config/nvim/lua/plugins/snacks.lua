return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    lazygit = { enabled = true },
    picker = {
      enabled = true,
    },
    terminal = {
      win = { style = "terminal", position = "float", border = "rounded" },
    },
  },
  keys = {
    { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>th", function() Snacks.terminal.toggle(nil, { win = { position = "bottom" } }) end, desc = "Toggle Horizontal Terminal", mode = { "n", "t" } },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
}
