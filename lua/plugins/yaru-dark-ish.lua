return {
  "dapc11/yaru-dark-ish.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("yaru-dark-ish")
    -- The terminal can only be asked for its background asynchronously, so the
    -- derived palette lands shortly after the first paint.
    require("user.terminal-bg").detect(function(palette)
      if not palette then
        return
      end
      vim.g.yaru_color_overrides = palette
      vim.cmd.colorscheme("yaru-dark-ish")
    end)
  end,
}
