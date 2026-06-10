return {
  "lewis6991/gitsigns.nvim",
  config = function()
    local gs = require("gitsigns")
    gs.setup({})

    -- Navigate hunks (respects diff mode)
    vim.keymap.set("n", "]c", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, { desc = "Next git hunk" })

    vim.keymap.set("n", "[c", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
    end, { desc = "Previous git hunk" })

    vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
    vim.keymap.set("n", "<leader>hr", gs.reset_hunk,   { desc = "Reset hunk" })
  end,
}
