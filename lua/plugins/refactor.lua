return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
    vim.keymap.set("x", "<leader>cre", function()
      require("refactoring").refactor("Extract Function")
    end)
    vim.keymap.set("x", "<leader>crf", function()
      require("refactoring").refactor("Extract Function To File")
    end)
    -- Extract function supports only visual mode
    vim.keymap.set("x", "<leader>crv", function()
      require("refactoring").refactor("Extract Variable")
    end)
    -- Extract variable supports only visual mode
    vim.keymap.set({ "n", "x" }, "<leader>cri", function()
      require("refactoring").refactor("Inline Variable")
    end)
    -- Inline var supports both normal and visual mode
    vim.keymap.set("n", "<leader>crb", function()
      require("refactoring").refactor("Extract Block")
    end)
  end,
}
