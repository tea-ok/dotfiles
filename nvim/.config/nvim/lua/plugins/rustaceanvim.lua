return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false, -- plugin handles its own lazy loading via ftplugin
  init = function()
    vim.g.rustaceanvim = {
      server = {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
          },
        },
      },
    }
  end,
}
