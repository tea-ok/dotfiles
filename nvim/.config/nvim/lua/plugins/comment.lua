return {
  "numToStr/Comment.nvim",
  version = "v0.8.0",
  lazy = false,
  opts = {
    pre_hook = function()
      return vim.bo.commentstring
    end,
  },
}
