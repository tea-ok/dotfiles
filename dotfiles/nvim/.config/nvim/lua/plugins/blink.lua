return {
  "saghen/blink.cmp",
  version = "1.*",

  opts = {
    -- Keybindings
    --   C-j/k  → next/prev item
    --   Tab/S-Tab → same, with fallback
    --   CR  → accept (select = true means accept even without explicit navigation)
    --   C-Space → force-open the menu
    --   C-e → dismiss
    --   C-b/C-f → scroll docs
    keymap = {
      preset = "none",
      ["<C-j>"]     = { "select_next",               "fallback" },
      ["<C-k>"]     = { "select_prev",               "fallback" },
      ["<Tab>"]     = { "select_next", "snippet_forward",  "fallback" },
      ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"]      = { "accept",                    "fallback" },
      ["<C-Space>"] = { "show",                      "fallback" },
      ["<C-e>"]     = { "hide",                      "fallback" },
      ["<C-b>"]     = { "scroll_documentation_up",   "fallback" },
      ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
    },

    appearance = {
      -- Use the single-width (mono) variant of Nerd Font icons
      nerd_font_variant = "mono",
    },

    sources = {
      default = { "lsp", "path", "buffer" },
    },

    completion = {
      -- Accept the first item on CR even when nothing is explicitly selected
      list = { selection = { preselect = true, auto_insert = false } },

      menu = {
        border = "none",
        draw = {
          -- kind-icon | label + description | [source]
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "none" },
      },
    },
  },
}
