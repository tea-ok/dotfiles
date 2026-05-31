return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local opts = function(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Start with all defaults, then override split/tab keys to match NERDTree
        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.del("n", "<C-v>", { buffer = bufnr })
        vim.keymap.del("n", "<C-x>", { buffer = bufnr })
        vim.keymap.del("n", "<C-t>", { buffer = bufnr })
        vim.keymap.del("n", "s",     { buffer = bufnr }) -- was "system open"

        vim.keymap.set("n", "s", api.node.open.vertical,   opts("Open: Vertical Split"))
        vim.keymap.set("n", "i", api.node.open.horizontal, opts("Open: Horizontal Split"))
        vim.keymap.set("n", "t", api.node.open.tab,        opts("Open: New Tab"))
      end,
    })

    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>")
  end,
}
