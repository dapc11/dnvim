return {
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  -- {
  --   "zk-org/zk-nvim",
  --   opts = {
  --     picker = "fzf_lua",
  --   },
  --   config = function(_, opts)
  --     require("zk").setup(opts)
  --   end,
  --   keys = {
  --     {
  --       "<leader>zn",
  --       "<cmd>ZkNew { dir = vim.fn.expand('$HOME/notes'), title = vim.fn.input('Title: ') }<CR>",
  --       desc = "New Note",
  --     },
  --     { "<leader>zb", vim.cmd.ZkNotes, desc = "Browse Notes" },
  --     { "<leader>zz", "<cmd>FzfLua live_grep cwd=~/notes<CR>", desc = "Find Note" },
  --   },
  -- },
}
