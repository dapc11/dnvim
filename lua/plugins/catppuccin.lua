return {
  "catppuccin/nvim",
  enabled = true,
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      highlight_overrides = {
        macchiato = function(colors)
          return {
            LineNr = { fg = colors.text },
            CursorLineNr = { fg = colors.text },
          }
        end,
      },
    })
    vim.cmd("colorscheme catppuccin-macchiato")
  end,
}
