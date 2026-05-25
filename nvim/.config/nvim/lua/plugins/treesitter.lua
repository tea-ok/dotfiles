return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  build = ":TSUpdate",

  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "c",
        "cpp",
        "rust",
        "python",
        "html",
        "css",
        "javascript",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "toml",
        "bash",
      },

      sync_install = false,
      auto_install = true,
      autopairs = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    })

    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move  = { set_jumps = true },
    })

    local sel  = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    local function has_parser()
      local ok, parser = pcall(vim.treesitter.get_parser, 0)
      return ok and parser ~= nil
    end

    -- Text object selects (visual + operator-pending)
    local select_maps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    }
    for key, query in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, key, function()
        if not has_parser() then
          vim.notify("No treesitter parser for this filetype (run :TSInstall " .. vim.bo.filetype .. ")", vim.log.levels.WARN)
          return
        end
        sel.select_textobject(query, "textobjects")
      end, { desc = "Textobject " .. key })
    end

    -- Motion keymaps (normal + visual + operator-pending)
    local function nxo(lhs, fn, desc)
      vim.keymap.set({ "n", "x", "o" }, lhs, function()
        if not has_parser() then
          vim.notify("No treesitter parser for this filetype (run :TSInstall " .. vim.bo.filetype .. ")", vim.log.levels.WARN)
          return
        end
        fn()
      end, { desc = desc })
    end

    -- _end variants (]M, [M, ][, []) omitted: bug in this version of the plugin
    -- where Range4 nodes cause a nil comparison in scoring_function(range[6])
    nxo("]m", function() move.goto_next_start("@function.outer",    "textobjects") end, "Next function start")
    nxo("[m", function() move.goto_previous_start("@function.outer","textobjects") end, "Prev function start")
    nxo("]]", function() move.goto_next_start("@class.outer",       "textobjects") end, "Next class start")
    nxo("[[", function() move.goto_previous_start("@class.outer",   "textobjects") end, "Prev class start")
  end,
}
