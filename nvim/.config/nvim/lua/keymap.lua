local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)


keymap("n", "<C-Up>", ":resize +1<CR>", opts)
keymap("n", "<C-Down>", ":resize -1<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -1<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +1<CR>", opts)

keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>x", "<cmd>lua Snacks.bufdelete()<CR>", opts)

keymap("n", "Q", "<nop>", opts)
keymap("n", "<Esc>", ":noh<CR>", opts)

-- Visual --
keymap("v", "p", '"_dP', opts)

-- Visual Block --
keymap("x", "J", ":move '>+1<CR>gv=gv", opts)
keymap("x", "K", ":move '<-2<CR>gv=gv", opts)
keymap("x", "p", '"_dP', opts)

-- Terminal --
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Neovide clipboard (Cmd+C/V) --
if vim.g.neovide then
    vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', opts)
    vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', opts)
    vim.keymap.set("i", "<D-v>", "<C-r><C-o>+", opts)
    vim.keymap.set("t", "<D-v>", function()
        local clip = vim.fn.getreg("+")
        local channel = vim.b.terminal_job_id
        if channel then
            vim.api.nvim_chan_send(channel, clip)
        end
    end, opts)
    vim.keymap.set("t", "<D-c>", "<C-\\><C-N>", opts)
end
