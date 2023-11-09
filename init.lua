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
vim.cmd([[
nmap > [
nmap < ]
omap > [
omap < ]
xmap > [
xmap < ]
]])

require("lazy").setup({
  spec = {
    -- libs
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
    -- plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
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
  vim.g.neovide_cursor_animation_length = 0.0
  vim.g.neovide_cursor_trail_size = 0.4
  vim.g.neovide_scroll_animation_length = 0.4
  vim.g.neovide_cursor_vfx_mode = ""
end

require("config.options")
require("config.autocmds")
require("config.keymaps")
vim.cmd([[
nmap > [
nmap < ]
omap > [
omap < ]
xmap > [
xmap < ]
]])
local should_profile = os.getenv("NVIM_PROFILE")
if should_profile then
  require("profile").instrument_autocmds()
  if should_profile:lower():match("^start") then
    require("profile").start("*")
  else
    require("profile").instrument("*")
  end
end

local function toggle_profile()
  local prof = require("profile")
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format("Wrote %s", filename))
      end
    end)
  else
    prof.start("*")
  end
end
vim.keymap.set("", "<leader>lp", toggle_profile)
