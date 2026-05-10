return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  module = "telescope",

  config = function()
    require('telescope').setup({
      defaults = {
        preview = { treesitter = false },
        mappings = {
          n = { ["q"] = require("telescope.actions").close },
        },
      },
    })

    local builtin = require('telescope.builtin')

    vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
    vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    vim.keymap.set("n", "<leader>fh", function()
      builtin.find_files({
        hidden = true,
        file_ignore_patterns = { "^%.git/", "^%.claude/" },
      })
    end)
  end
}
