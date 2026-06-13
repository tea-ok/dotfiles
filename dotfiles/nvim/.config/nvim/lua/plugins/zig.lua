return {
  "ziglang/zig.vim",
  url = "https://codeberg.org/ziglang/zig.vim",
  ft = { "zig", "zon" },
  init = function()
    vim.g.zig_fmt_parse_errors = 0
    vim.g.zig_fmt_autosave = 0
  end,
}
