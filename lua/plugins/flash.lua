return {
  "folke/flash.nvim",
  event = lazyfile,
  opts = {
    modes = { char = { enabled = false } },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump({ search = { forward = true, multi_window = false, wrap = false } })
      end,
      desc = "Flash",
    },
    {
      "S",
      mode = { "n", "o", "x" },
      function()
        require("flash").jump({ search = { forward = false, multi_window = false, wrap = false } })
      end,
      desc = "Flash Backwards",
    },
  },
}

