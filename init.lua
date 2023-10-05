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

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
  spec = {
    -- libs
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
    -- plugins
    { import = "plugins" },
    { import = "plugins.coding" },
  },
  defaults = {
    lazy = false,
    version = false,
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
})

if vim.g.neovide then
  vim.g.neovide_theme = "auto"
  vim.o.guifont = "Liga_SFMono_Nerd_Font,SauceCodePro_Nerd_Font,SF_Pro_Display,JetBrains_Mono,Apple_Color_Emoji:h10"
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.4
  vim.g.neovide_cursor_vfx_mode = ""
end

require("config.options")
require("config.autocmds")
require("config.keymaps")
