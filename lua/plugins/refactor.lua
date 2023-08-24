return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
    vim.keymap.set("x", "<leader>cee", function()
      require("refactoring").refactor("Extract Function")
    end)
    vim.keymap.set("x", "<leader>cef", function()
      require("refactoring").refactor("Extract Function To File")
    end)
    -- Extract function supports only visual mode
    vim.keymap.set("x", "<leader>cev", function()
      require("refactoring").refactor("Extract Variable")
    end)
    -- Extract variable supports only visual mode
    vim.keymap.set({ "n", "x" }, "<leader>cei", function()
      require("refactoring").refactor("Inline Variable")
    end)
    -- Inline var supports both normal and visual mode
    vim.keymap.set("n", "<leader>ceb", function()
      require("refactoring").refactor("Extract Block")
    end)
  end,
}
