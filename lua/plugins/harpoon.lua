return {
  {
    "cbochs/grapple.nvim",
    opts = {
      scope = "global", -- also try out "git_branch"
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    keys = {
      { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
      { "<leader><Up>", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
      { "<leader><Right>", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
      { "<leader><Left>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
    },
  },
}
