return {
  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>fe",
        function()
          require("mini.files").open()
        end,
        desc = "Explorer (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer", remap = true },
    },
    opts = {
      mappings = {
        go_in = "<Right>",
        go_in_plus = "<C-Right>",
        go_out = "<Left>",
        go_out_plus = "<C-Left>",
      },
    },
  },
}
