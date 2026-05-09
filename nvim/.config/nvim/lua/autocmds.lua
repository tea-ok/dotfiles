require "nvchad.autocmds"

local function apply_hl_overrides()
  -- Floating windows: solid dark background + gruvbox yellow border
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282828" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#d79921" })
  vim.api.nvim_set_hl(0, "FloatTitle",  { fg = "#d79921", bold = true })
  -- WhichKey: gruvbox-consistent colors (keys=yellow, desc=text, group=green)
  vim.api.nvim_set_hl(0, "WhichKey",          { fg = "#d6b676", bold = true })
  vim.api.nvim_set_hl(0, "WhichKeyDesc",      { fg = "#c7b89d" })
  vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#606364" })
  vim.api.nvim_set_hl(0, "WhichKeyGroup",     { fg = "#89b482" })
  vim.api.nvim_set_hl(0, "WhichKeyNormal",    { bg = "#282828" })
  vim.api.nvim_set_hl(0, "WhichKeyBorder",   { fg = "#d79921", bg = "#282828" })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_hl_overrides })
vim.schedule(apply_hl_overrides)

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
