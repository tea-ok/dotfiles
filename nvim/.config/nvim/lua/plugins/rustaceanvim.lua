return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false, -- plugin handles its own lazy loading via ftplugin
  init = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>ra", function()
            vim.cmd.RustLsp("codeAction")
          end, { buffer = bufnr, silent = true, desc = "Rust code actions" })
        end,
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
          },
        },
      },
    }
  end,
}
