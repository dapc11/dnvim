return {
  "nvimdev/indentmini.nvim",
  config = function()
    local indent_color = "#6e738d"
    vim.cmd.highlight("IndentLine guifg=" .. indent_color)
    vim.cmd.highlight("IndentLineCurrent guifg=" .. indent_color)
    require("indentmini").setup({ only_current = true }) -- use default config
  end,
}
