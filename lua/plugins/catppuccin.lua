return {
  "catppuccin/nvim",
  enabled = false,
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      term_colors = true,
    })
    vim.cmd("colorscheme catppuccin-nvim")
  end,
}
