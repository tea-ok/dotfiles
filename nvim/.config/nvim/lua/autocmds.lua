require "nvchad.autocmds"

-- Make floating windows (LSP hover, etc.) stand out with a solid dark background
-- and a gruvbox yellow border instead of blending into the transparent editor bg.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1d2021" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#d79921" })
    vim.api.nvim_set_hl(0, "FloatTitle",  { fg = "#d79921", bold = true })
  end,
})

-- Also apply immediately for the initial load (ColorScheme won't fire at startup)
vim.schedule(function()
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1d2021" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#d79921" })
  vim.api.nvim_set_hl(0, "FloatTitle",  { fg = "#d79921", bold = true })
end)

-- In nvim 0.11+ pass border directly to hover/signatureHelp via LspAttach,
-- overriding NvChad's K mapping so the float always gets a rounded border.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, { buffer = buf, silent = true })
    vim.keymap.set({ "n", "i" }, "<C-k>", function()
      vim.lsp.buf.signature_help({ border = "rounded" })
    end, { buffer = buf, silent = true })
  end,
})
