return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>ss", "<cmd>AutoSession search<CR>", desc = "Search workspace sessions" },
    { "<leader>sl", "<cmd>AutoSession restore<CR>", desc = "Restore workspace session" },
    { "<leader>sw", "<cmd>AutoSession save<CR>", desc = "Save workspace session" },
    { "<leader>st", "<cmd>AutoSession toggle<CR>", desc = "Toggle workspace autosave" },
  },
  opts = {
    auto_restore_last_session = false,
    close_unsupported_windows = true,
    session_lens = {
      picker = "snacks",
    },
    suppressed_dirs = { "~/Downloads", "/" },
  },
}
