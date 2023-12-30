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
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
    {
      "rebelot/kanagawa.nvim",
      config = function(_, opts)
        require("kanagawa").setup(vim.tbl_extend("force", opts, {
          colors = {
            theme = {
              all = {
                ui = {
                  bg_gutter = "none",
                },
              },
            },
          },
          overrides = function(colors)
            local theme = colors.theme
            return {
              StatusLine = { bg = colors.palette.winterBlue },
              StatusLineNC = { bg = colors.palette.winterBlue },
              Error = { fg = colors.palette.autumnRed },
              DiagnosticError = { fg = colors.palette.autumnRed },
              DiagnosticSignError = { fg = colors.palette.autumnRed },
              ErrorMsg = { fg = colors.palette.autumnRed, bg = colors.palette.sumilnk0 },
              Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
              PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
              PmenuSbar = { bg = theme.ui.bg_m1 },
              PmenuThumb = { bg = theme.ui.bg_p2 },
            }
          end,
        }))
      end,
      lazy = false,
    },
    { "rose-pine/neovim", name = "rose-pine" },
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
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
vim.cmd("colorscheme kanagawa")
require("config.options")
require("config.autocmds")
require("config.keymaps")

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
