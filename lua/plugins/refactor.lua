return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },
  keys = function()
    local rf = require("refactoring").refactor
    return {
      {
        "<leader>rf",
        function()
          rf("Extract Function")
        end,
        mode = "x",
        desc = "Extract Function",
      },
      {
        "<leader>rv",
        function()
          rf("Extract Variable")
        end,
        mode = "x",
        desc = "Extract Variable",
      },
      {
        "<leader>rr",
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        mode = { "n", "x" },
        desc = "Refactoring Actions",
      },
    }
  end,
  config = function()
    require("refactoring").setup()
    require("telescope").load_extension("refactoring")
  end,
}
