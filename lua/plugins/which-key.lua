return {
  "folke/which-key.nvim",
  opts = {
    -- plugins = { spelling = true },
    -- defaults = {
    --   mode = { "n", "v" },
    --   { "<leader><tab>", group = "tabs" },
    --   { "<leader><tab>_", hidden = true },
    --   { "<leader>c", group = "code" },
    --   { "<leader>c_", hidden = true },
    --   { "<leader>g", group = "git" },
    --   { "<leader>g_", hidden = true },
    --   { "<leader>gp", group = "push" },
    --   { "<leader>gp_", hidden = true },
    --   { "<leader>h", group = "hunks" },
    --   { "<leader>h_", hidden = true },
    --   { "<leader>l", group = "misc" },
    --   { "<leader>l_", hidden = true },
    --   { "<leader>q", group = "quit/session" },
    --   { "<leader>q_", hidden = true },
    --   { "<leader>w", group = "windows" },
    --   { "<leader>w_", hidden = true },
    --   { "<leader>x", group = "misc" },
    --   { "<leader>x_", hidden = true },
    --   { "<leader>z", group = "notes" },
    --   { "<leader>z_", hidden = true },
    --   { "[", group = "prev" },
    --   { "[_", hidden = true },
    --   { "]", group = "next" },
    --   { "]_", hidden = true },
    --   { "g", group = "goto" },
    --   { "g_", hidden = true },
    --   { "gs", group = "surround" },
    --   { "gs_", hidden = true },
    --   { "gz", group = "asterisk" },
    --   { "gz_", hidden = true },
    -- },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    -- wk.register(opts.defaults)
  end,
}
