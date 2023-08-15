return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- stylua: ignore
  keys = {
    {
      "<leader><Right>",
      function()
        require("harpoon.ui").nav_next()
      end,
      desc = "Harpoon next",
    },
    {
      "<leader><Left>",
      function()
        require("harpoon.ui").nav_prev()
      end,
      desc = "Harpoon previous",
    },
    {
      "<leader><Up>",
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      desc = "Harpoon menu",
    },
    {
      "<leader>m",
      function()
        require("harpoon.mark").add_file()
      end,
      desc = "Harpoon add",
    },
    {
      "<A-q>",
      function()
        require("harpoon.ui").nav_file(1)
      end,
      desc = "Harpoon 1",
    },
    {
      "<A-w>",
      function()
        require("harpoon.ui").nav_file(2)
      end,
      desc = "Harpoon 2",
    },
    {
      "<A-e>",
      function()
        require("harpoon.ui").nav_file(3)
      end,
      desc = "Harpoon 3",
    },
    {
      "<A-r>",
      function()
        require("harpoon.ui").nav_file(4)
      end,
      desc = "Harpoon 4",
    },
    {
      "<A-t>",
      function()
        require("harpoon.ui").nav_file(5)
      end,
      desc = "Harpoon 5",
    },
    {
      "<A-y>",
      function()
        require("harpoon.ui").nav_file(6)
      end,
      desc = "Harpoon 6",
    },
  },
}
