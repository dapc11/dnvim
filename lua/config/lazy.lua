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
    change_detection = {
      enabled = false,
      notify = false,
    },
    git = {
      -- defaults for the `Lazy log` command
      -- log = { "--since=3 days ago" }, -- show commits from the last 3 days
      log = { "-8" }, -- show the last 8 commits
      timeout = 2120, -- kill processes that take more than 2 minutes
    },
  })
  require("lazy").setup(opts)
end
