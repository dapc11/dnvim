return {
  "catppuccin/nvim",
  enabled = true,
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({})
    vim.cmd("colorscheme catppuccin-macchiato")
  end,
}
