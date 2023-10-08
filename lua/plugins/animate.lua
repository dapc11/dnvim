return {
  {
    "echasnovski/mini.animate",
    version = false,
    enabled = false,
    opts = function()
      return {
        cursor = {
          enable = false,
        },
        scroll = {
          -- Animate for 200 milliseconds with linear easing
          timing = require("mini.animate").gen_timing.linear({ duration = 200, unit = "total" }),

          -- Animate equally but with at most 120 steps instead of default 60
          subscroll = require("mini.animate").gen_subscroll.equal({ max_output_steps = 300 }),
        },
      }
    end,
  },
}
