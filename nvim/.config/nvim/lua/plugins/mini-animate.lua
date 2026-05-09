return {
  "echasnovski/mini.animate",
  version = false,
  lazy = false,
  opts = function()
    local animate = require "mini.animate"

    return {
      open = { enable = false },
      close = { enable = false },
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
