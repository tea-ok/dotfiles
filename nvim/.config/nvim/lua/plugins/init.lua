return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "mason-org/mason.nvim",
    event = "User FilePost",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = function()
      return require("configs.mason").opts
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      require("configs.mason").install_missing()
    end,
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "configs.treesitter",
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
  },

  {
    "echasnovski/mini.icons",
    version = false,
    opts = {},
  },

  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.animate",
    version = false,
    lazy = false,
    opts = {
      open = { enable = false },
      close = { enable = false },
      cursor = { enable = false },
    },
  },

  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {
      hide_target_hack = true,
      cursor_color = "none",
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      stiffness_insert_mode = 0.7,
      trailing_stiffness_insert_mode = 0.7,
      damping = 0.95,
      damping_insert_mode = 0.95,
      distance_stop_animating = 0.5,
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      local group = vim.api.nvim_create_augroup("snacks_solid_floats", { clear = true })

      local function apply()
        vim.api.nvim_set_hl(0, "SnacksSolidFloat", { bg = "#1f2430" })
        vim.api.nvim_set_hl(0, "SnacksSolidBorder", { fg = "#5c6370", bg = "#1f2430" })
      end

      apply()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = apply,
      })
    end,
    opts = {
      dashboard = {
        enabled = true,
      },
      terminal = {
        win = { position = "float" },
      },
      lazygit = {},
      styles = {
        terminal = {
          backdrop = 60,
          border = "rounded",
          wo = {
            winblend = 0,
            winhighlight = {
              Normal = "SnacksSolidFloat",
              NormalNC = "SnacksSolidFloat",
              FloatBorder = "SnacksSolidBorder",
            },
          },
        },
        lazygit = {
          backdrop = 60,
          border = "rounded",
          wo = {
            winblend = 0,
            winhighlight = {
              Normal = "SnacksSolidFloat",
              NormalNC = "SnacksSolidFloat",
              FloatBorder = "SnacksSolidBorder",
            },
          },
        },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ft = { "markdown" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    config = function()
      require("grug-far").setup {}
    end,
  },
}
