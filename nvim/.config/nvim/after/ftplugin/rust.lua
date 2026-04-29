local bufnr = vim.api.nvim_get_current_buf()

local function rust_lsp(args, fallback)
  if vim.fn.exists(":RustLsp") == 2 then
    vim.cmd.RustLsp(args)
    return
  end

  if fallback then
    fallback()
    return
  end

  vim.notify("rust-analyzer is not ready yet", vim.log.levels.WARN)
end

vim.keymap.set("n", "<leader>rr", function()
  rust_lsp "runnables"
end, { buffer = bufnr, desc = "Rust runnables", silent = true })

vim.keymap.set("n", "<leader>rt", function()
  rust_lsp "testables"
end, { buffer = bufnr, desc = "Rust testables", silent = true })
