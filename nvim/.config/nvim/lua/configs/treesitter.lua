pcall(function()
  dofile(vim.g.base46_cache .. "syntax")
  dofile(vim.g.base46_cache .. "treesitter")
end)

return {
  ensure_installed = {
    "vim",
    "vimdoc",
    "lua",
    "luadoc",
    "printf",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "jsonc",
    "yaml",
    "toml",
    "bash",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "python",
    "dockerfile",
    "terraform",
    "hcl",
    "markdown",
    "markdown_inline",
    "latex",
  },
  auto_install = true,
}
