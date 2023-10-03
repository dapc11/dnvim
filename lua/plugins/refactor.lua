return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
    local map = require("util").map
    map("x", "<leader>ce", function()
      require("refactoring").refactor("Extract Function")
    end, { desc = "Extract Function" })
    map("x", "<leader>cf", function()
      require("refactoring").refactor("Extract Function To File")
    end, { desc = "Extract Function to File" })
    map("x", "<leader>cv", function()
      require("refactoring").refactor("Extract Variable")
    end, { desc = "Extract Variable" })
    map({ "n", "x" }, "<leader>ci", function()
      require("refactoring").refactor("Inline Variable")
    end, { desc = "Inline Variable" })
    map("n", "<leader>cb", function()
      require("refactoring").refactor("Extract Block")
    end, { desc = "Extract Block" })
  end,
}
