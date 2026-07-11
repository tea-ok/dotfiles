return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  build = ":TSUpdate",

  config = function()
    local treesitter = require("nvim-treesitter")
    local ts_config = require("nvim-treesitter.config")
    local parser_configs = require("nvim-treesitter.parsers")

    treesitter.setup()

    local ensure_installed = {
      "c",
      "cpp",
      "rust",
      "go",
      "gomod",
      "gosum",
      "python",
      "html",
      "markdown",
      "markdown_inline",
      "css",
      "javascript",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "toml",
      "bash",
      "nix",
      "zig",
      "haskell",
    }

    local function supported(languages)
      return vim.tbl_filter(function(lang)
        return parser_configs[lang] ~= nil
      end, languages)
    end

    local function installed_set()
      local installed = {}
      for _, lang in ipairs(ts_config.get_installed("parsers")) do
        installed[lang] = true
      end
      return installed
    end

    local function missing(languages)
      local installed = installed_set()
      return vim.tbl_filter(function(lang)
        return not installed[lang]
      end, supported(languages))
    end

    local parsers_to_install = missing(ensure_installed)
    if #parsers_to_install > 0 then
      treesitter.install(parsers_to_install)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match) or args.match
        if not parser_configs[lang] then
          return
        end

        local function start()
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end

          local ok = pcall(vim.treesitter.start, args.buf, lang)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if installed_set()[lang] then
          start()
          return
        end

        if vim.list_contains(ensure_installed, lang) then
          local task = treesitter.install({ lang }, { summary = false })
          if task and task.wait then
            pcall(function()
              task:wait(60000)
            end)
          end
          start()
        end
      end,
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
