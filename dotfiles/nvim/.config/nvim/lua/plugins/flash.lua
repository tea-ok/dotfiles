return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    -- s: jump to any position with 2-char label
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,            desc = "Flash jump" },
    -- S: select a treesitter node to jump to (normal/operator only — visual S is surround)
    { "S", mode = { "n", "o" },      function() require("flash").treesitter() end,      desc = "Flash treesitter" },
    -- r: remote flash — apply operator on a distant location without moving cursor
    { "r", mode = "o",               function() require("flash").remote() end,           desc = "Flash remote" },
    -- R: treesitter search across the buffer
    { "R", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
  },
}
