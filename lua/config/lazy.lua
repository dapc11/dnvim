local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return function(opts)
  opts = opts or {}
  opts = vim.tbl_extend("force", opts, {
    spec = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
      { "MunifTanjim/nui.nvim", lazy = true },
      { import = "plugins" },
    },
    icons = require("config.icons"),
  })
  require("lazy").setup(opts)
end
