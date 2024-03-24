local group = "murmur"
return {
  "nyngwang/murmur.lua",
  config = function()
    require("murmur").setup()
    vim.api.nvim_create_augroup(group, { clear = true })
    vim.api.nvim_create_autocmd({ "ColorScheme" }, {
      group = group,
      pattern = "onedark",
      callback = function()
        local colors = require("onedark.palette").dark
        vim.api.nvim_set_hl(0, "murmur_cursor_rgb", { bg = colors.bg3, underline = true })
      end,
    })
  end,
}
