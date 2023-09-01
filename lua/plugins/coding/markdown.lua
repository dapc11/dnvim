return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown" })
      end
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "mickael-menu/zk-nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      picker = "telescope",
    },
    config = function(_, opts)
      require("zk").setup(opts)
    end,
    keys = {
      {
        "<leader>zn",
        "<cmd>ZkNew { dir = vim.fn.expand('$HOME/notes'), title = vim.fn.input('Title: ') }<CR>",
        desc = "New Note",
      },
      { "<leader>zb", vim.cmd.ZkNotes, desc = "Browse Notes" },
      { "<leader>zz", "<cmd>Telescope live_grep cwd=~/notes<CR>", desc = "Find Note" },
    },
  },
}
