require "nvchad.options"

-- add yours here!

local o = vim.o
o.cmdheight = 0
o.number = true
o.relativenumber = true

vim.diagnostic.config {
  float = { border = "rounded" },
}
