require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- vim-tmux-navigator: override NvChad defaults and support terminal mode.
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "tmux navigate left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "tmux navigate down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "tmux navigate up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "tmux navigate right" })
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { desc = "tmux navigate previous" })

-- Use terminal-window command prefix in terminal mode to avoid literal command injection.
map("t", "<C-h>", "<C-w><cmd>TmuxNavigateLeft<CR>", { desc = "tmux navigate left" })
map("t", "<C-j>", "<C-w><cmd>TmuxNavigateDown<CR>", { desc = "tmux navigate down" })
map("t", "<C-k>", "<C-w><cmd>TmuxNavigateUp<CR>", { desc = "tmux navigate up" })
map("t", "<C-l>", "<C-w><cmd>TmuxNavigateRight<CR>", { desc = "tmux navigate right" })
map("t", "<C-\\>", "<C-w><cmd>TmuxNavigatePrevious<CR>", { desc = "tmux navigate previous" })

-- grug-far --
map("n", "<leader>fr", "<cmd>GrugFar<cr>", { desc = "Find & Replace (grug-far)" })
map("v", "<leader>fr", "<cmd>GrugFar<cr>", { desc = "Find & Replace selection (grug-far)" })
