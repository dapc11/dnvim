return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- stylua: ignore
  keys = {
    { "<leader><Right>", function() require("harpoon.ui").nav_next() end, desc = "Harpoon Next" },
    { "<leader><Left>", function() require("harpoon.ui").nav_prev() end, desc = "Harpoon Previous" },
    { "<leader><Up>", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon Menu" },
    { "<leader>m", function() require("harpoon.mark").add_file() end, desc = "Harpoon Add" },
    { "<leader>1", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon 1" },
    { "<leader>2", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon 2" },
    { "<leader>3", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon 3" },
    { "<leader>4", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon 4" },
    { "<leader>5", function() require("harpoon.ui").nav_file(5) end, desc = "Harpoon 5" },
    { "<leader>6", function() require("harpoon.ui").nav_file(6) end, desc = "Harpoon 6" },
  },
}
