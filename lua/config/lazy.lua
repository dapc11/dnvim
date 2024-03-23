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
    defaults = {
      lazy = false,
    },
    checker = { enabled = false },
    change_detection = {
      enabled = true,
      notify = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "tarPlugin",
          "tohtml",
          "rplugin",
          "tutor",
          "editorconfig",
          "netrwPlugin",
          "zipPlugin",
        },
      },
    },
    icons = require("config.icons"),
    ui = {
      size = { width = 0.8, height = 0.8 },
      wrap = true,
      border = "rounded",
    },
  })
  require("lazy").setup(opts)
end
