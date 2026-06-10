return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost" },

  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      markdown = { "markdownlint-cli2" },
    }

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
