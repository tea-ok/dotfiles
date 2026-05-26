return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      python = { "ruff_format" },
      -- Rust: use LSP (rust-analyzer runs rustfmt)
      rust   = { lsp_format = "first" },
      -- Lua: use stylua if available, otherwise LSP
      lua    = { "stylua", lsp_format = "fallback" },
      -- Go: use LSP (gopls runs gofmt + organizes imports)
      go     = { lsp_format = "first" },
    },
    -- format_after_save is async-friendly; LSP may not be ready on first save
    -- with format_on_save (sync). Using after_save lets the LSP attach first.
    format_after_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
