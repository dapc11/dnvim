return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
<<<<<<< HEAD
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
=======
    vim.keymap.set("x", "<leader>ce", function()
      require("refactoring").refactor("Extract Function")
    end, { desc = "Extract Function" })
    vim.keymap.set("x", "<leader>cf", function()
      require("refactoring").refactor("Extract Function To File")
    end, { desc = "Extract Function To File" })
    vim.keymap.set("x", "<leader>cv", function()
      require("refactoring").refactor("Extract Variable")
    end, { desc = "Extract Variable" })
    vim.keymap.set({ "n", "x" }, "<leader>ci", function()
      require("refactoring").refactor("Inline Variable")
    end, { desc = "Inline Variable" })
    vim.keymap.set("n", "<leader>cb", function()
>>>>>>> de9bdd0 (Fix refactor.nvim)
      require("refactoring").refactor("Extract Block")
    end, { desc = "Extract Block" })
  end,
}
