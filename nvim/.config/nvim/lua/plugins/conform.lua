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
    formatters = {
      -- markdownlint-cli2 modifies files in place (no stdout), so stdin = false.
      -- It also exits 1 when violations are found even after fixing them.
      ["markdownlint-cli2"] = {
        command = "markdownlint-cli2",
        args = { "--fix", "$FILENAME" },
        stdin = false,
        exit_codes = { 0, 1 },
      },
    },
    formatters_by_ft = {
      python = { "ruff_format" },
      -- Rust: use LSP (rust-analyzer runs rustfmt)
      rust   = { lsp_format = "first" },
      -- Lua: use stylua if available, otherwise LSP
      lua    = { "stylua", lsp_format = "fallback" },
      -- Go: use LSP (gopls runs gofmt + organizes imports)
      go       = { lsp_format = "first" },
      -- Markdown: markdownlint-cli2 fixes style violations on save
      markdown   = { "markdownlint-cli2" },
      nix        = { "nixfmt" },
      -- Prettier-handled filetypes
      html       = { "prettier" },
      css        = { "prettier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      json       = { "prettier" },
      yaml       = { "prettier" },
      graphql    = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
