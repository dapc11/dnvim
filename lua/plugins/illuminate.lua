return {
  {
    "RRethy/vim-illuminate",
    config = function(_, opts)
      local illuminate = require("illuminate")
      illuminate.configure(opts)

      vim.keymap.set("n", "<h", function()
        illuminate.goto_next_reference()
      end, { desc = "Next todo comment" })
      vim.keymap.set("n", ">h", function()
        illuminate.goto_prev_reference()
      end, { desc = "Previous todo comment" })
    end,
    opts = {
      providers = {
        "treesitter",
      },
      delay = 100,
      filetypes_denylist = require("util.common").ignored_filetype,
      under_cursor = true,
      large_file_cutoff = 1000,
      min_count_to_highlight = 2,
    },
  },
}
