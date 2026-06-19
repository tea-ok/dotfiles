return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },

  config = function()
    local lsp_float_winhighlight = "Normal:LspFloatNormal,FloatBorder:LspFloatBorder"

    local function set_lsp_float_highlights()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local is_hover = pcall(vim.api.nvim_win_get_var, win, "textDocument/hover")
        local is_signature = pcall(vim.api.nvim_win_get_var, win, "textDocument/signatureHelp")

        if is_hover or is_signature then
          vim.wo[win].winhighlight = lsp_float_winhighlight
        end
      end
    end

    vim.api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
      callback = function()
        vim.schedule(set_lsp_float_highlights)
      end,
    })

    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = { current_line = true }, -- show inline text only on the cursor line
      signs = true,
      underline = { severity = vim.diagnostic.severity.ERROR }, -- only underline errors, not warnings
      update_in_insert = false,
      float = { border = "none" },
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local opts = {buffer = event.buf}

        vim.keymap.set('n', 'K', function()
          vim.lsp.buf.hover({ border = "none" })
        end, opts)
        vim.keymap.set('n', '<leader>k', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', function()
          vim.lsp.buf.signature_help({ border = "none" })
        end, opts)
        vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end,
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    require("mason").setup({})
    require("mason-lspconfig").setup({
      ensure_installed = { "ruff", "gopls" },
      automatic_enable = {
        exclude = { "rust_analyzer" }, -- managed by rustup, rustaceanvim finds it automatically
      },
    })

    if vim.fn.executable("nil") == 1 then
      vim.lsp.enable("nil_ls")
    end

    if vim.fn.executable("ty") == 1 then
      vim.lsp.config("ty", {
        cmd = { "ty", "server" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", ".git" },
      })
      vim.lsp.enable("ty")
    end

    if vim.fn.executable("zls") == 1 then
      vim.lsp.config("zls", {
        cmd = { "zls" },
        filetypes = { "zig", "zon" },
        root_markers = { "build.zig" },
      })
      vim.lsp.enable("zls")
    end
  end
}
