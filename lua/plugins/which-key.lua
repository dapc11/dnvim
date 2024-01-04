return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["gs"] = { name = "+surround" },
      ["gz"] = { name = "+asterisk" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader><tab>"] = { name = "+tabs" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>cb"] = { name = "+dispatch" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>gp"] = { name = "+push" },
      ["<leader>h"] = { name = "+hunks" },
      ["<leader>l"] = { name = "+misc" },
      ["<leader>q"] = { name = "+quit/session" },
      ["<leader>w"] = { name = "+windows" },
      ["<leader>x"] = { name = "+misc" },
      ["<leader>z"] = { name = "+notes" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
