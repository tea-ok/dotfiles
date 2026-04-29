return {
  require "plugins.conform",
  require "plugins.lspconfig",
  require "plugins.mason",

  -- test new blink
  { import = "nvchad.blink.lazyspec" },
  require "plugins.treesitter",
  require "plugins.rustaceanvim",
  require "plugins.tmux-navigator",
  require "plugins.mini-icons",
  require "plugins.nvim-surround",
  require "plugins.mini-animate",
  require "plugins.snacks",
  require "plugins.render-markdown",
  require "plugins.grug-far",
}
