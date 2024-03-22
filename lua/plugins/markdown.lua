local notes_dir = vim.fn.expand("$HOME/notes")
return {
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
        function()
          require("zk.commands").get("ZkNew")({ dir = notes_dir, title = vim.fn.input("Title: ") })
        end,
        desc = "New Note",
      },
      {
        "<leader>zb",
        function()
          require("zk.commands").get("ZkNotes")({ sort = "modified" })
        end,
        desc = "Browse Notes",
      },
      {
        "<leader>zs",
        function()
          require("telescope.builtin").live_grep({ cwd = notes_dir })
        end,
        desc = "Search Notes",
      },
    },
  },
}
