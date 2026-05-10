return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    lazygit = { enabled = true },
    terminal = {
      win = { style = "terminal" },
    },
  },
  keys = {
    { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
}
