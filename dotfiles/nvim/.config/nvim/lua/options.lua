local options = {
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 0,
  completeopt = { "menuone", "noselect" } ,
  conceallevel = 0,
  fileencoding = "utf-8",
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  ro = false,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 1000,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 4,
  tabstop = 4,
  cursorline = false,
  number = true,
  relativenumber = true,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = true,
  scrolloff = 4,
  sidescrolloff = 4,
}

if vim.g.neovide then
  local sysname = vim.uv and vim.uv.os_uname().sysname or vim.loop.os_uname().sysname

  if sysname == "Linux" then
    vim.o.guifont = "JetBrainsMono Nerd Font:h13"
    vim.g.neovide_opacity = 0.95
    vim.g.neovide_normal_opacity = 0.95
  else
    vim.o.guifont = "JetBrainsMono Nerd Font:h20"
  end
end

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_augroup("FileTypeSpecific", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "css", "javascript", "lua" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
    group = "FileTypeSpecific",
})

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

vim.opt.shortmess:append "c"
vim.opt.sessionoptions:append "localoptions"

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require('stl')()"
