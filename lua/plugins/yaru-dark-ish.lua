return {
  "dapc11/yaru-dark-ish.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local tb = require("user.terminal-bg").get()
    vim.g.yaru_color_overrides = tb and {
      normal_bg = "NONE",
      bg = tb.bg,
      darkbg = tb.darkbg,
      darker = tb.darker,
      surface0 = tb.surface0,
      surface1 = tb.surface1,
      surface2 = tb.surface2,
    } or nil
    vim.cmd.colorscheme("yaru-dark-ish")
  end,
}
