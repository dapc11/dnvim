return {
  "gbprod/yanky.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
    "folke/snacks.nvim",
  },
  opts = {
    ring = { storage = "sqlite" },
  },
  keys = {
    {
      "<leader>p",
      function() Snacks.picker.yanky() end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
  },
}
