require("nvchad.configs.lspconfig").defaults()

local servers = {
  "lua_ls",
  "html",
  "cssls",
  "jsonls",
  "yamlls",
  "taplo",
  "bashls",
  "marksman",
  "gopls",
  "pylsp",
  "dockerls",
  "docker_compose_language_service",
  "terraformls",
}

for _, server in ipairs(servers) do
  pcall(vim.lsp.enable, server)
end

-- nvim-lspconfig renamed tsserver -> ts_ls; support both names.
if not pcall(vim.lsp.enable, "ts_ls") then
  pcall(vim.lsp.enable, "tsserver")
end

-- read :h vim.lsp.config for changing options of lsp servers 
