return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "+goto", _ = 'which_key_ignore' },
      ["gs"] = { name = "+surround", _ = 'which_key_ignore' },
      ["gz"] = { name = "+asterisk", _ = 'which_key_ignore' },
      ["]"] = { name = "+next", _ = 'which_key_ignore' },
      ["["] = { name = "+prev", _ = 'which_key_ignore' },
      ["<leader><tab>"] = { name = "+tabs", _ = 'which_key_ignore' },
      ["<leader>c"] = { name = "+code", _ = 'which_key_ignore' },
      ["<leader>g"] = { name = "+git", _ = 'which_key_ignore' },
      ["<leader>gp"] = { name = "+push", _ = 'which_key_ignore' },
      ["<leader>h"] = { name = "+hunks", _ = 'which_key_ignore' },
      ["<leader>l"] = { name = "+misc", _ = 'which_key_ignore' },
      ["<leader>q"] = { name = "+quit/session", _ = 'which_key_ignore' },
      ["<leader>w"] = { name = "+windows", _ = 'which_key_ignore' },
      ["<leader>x"] = { name = "+misc", _ = 'which_key_ignore' },
      ["<leader>z"] = { name = "+notes", _ = 'which_key_ignore' },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
