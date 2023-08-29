return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
    vim.keymap.set("x", "<leader>ce", function()
      require("refactoring").refactor("Extract Function")
    end, { desc = "Extract Function" })
    vim.keymap.set("x", "<leader>cf", function()
      require("refactoring").refactor("Extract Function To File")
    end, { desc = "Extract Function to File" })
    vim.keymap.set("x", "<leader>cv", function()
      require("refactoring").refactor("Extract Variable")
    end, { desc = "Extract Variable" })
    vim.keymap.set({ "n", "x" }, "<leader>ci", function()
      require("refactoring").refactor("Inline Variable")
    end, { desc = "Inline Variable" })
    vim.keymap.set("n", "<leader>cb", function()
      require("refactoring").refactor("Extract Block")
    end, { desc = "Extract Block" })
  end,
}
