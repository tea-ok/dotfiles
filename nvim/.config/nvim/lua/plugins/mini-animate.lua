return {
  "echasnovski/mini.animate",
  version = false,
  lazy = false,
  opts = function()
    local animate = require "mini.animate"

    local not_nvimtree = function(win_id)
      local buf = vim.api.nvim_win_get_buf(win_id)
      return vim.bo[buf].filetype ~= "NvimTree"
    end

    return {
      open = {
        enable = true,
        winconfig = animate.gen_winconfig.static { predicate = not_nvimtree },
      },
      close = {
        enable = true,
        winconfig = animate.gen_winconfig.static { predicate = not_nvimtree },
      },
      cursor = { enable = false },
      scroll = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 70, unit = "total" }),
        subscroll = animate.gen_subscroll.equal({
          max_output_steps = 8,
          predicate = function(total_scroll)
            return total_scroll > 2
          end,
        }),
      },
    }
  end,
}
