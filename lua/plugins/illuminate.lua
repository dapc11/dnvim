return {
  {
    "RRethy/vim-illuminate",
    config = function(_, opts)
      local illuminate = require("illuminate")
      local map = require("util").map
      illuminate.configure(opts)

      map("n", "<h", function()
        illuminate.goto_next_reference()
      end, { desc = "Next todo comment" })
      map("n", ">h", function()
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
