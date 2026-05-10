return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    highlights = {
      fill = { bg = "NONE" },
    },
    options = {
      offsets = {
        { filetype = "NvimTree", text = "File Explorer", separator = true },
      },
    },
  },
}
