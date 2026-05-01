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
  "ruff",
  "ty",
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("python_lsp_prefer_ty_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end

    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Prefer ty hover for Python",
})
