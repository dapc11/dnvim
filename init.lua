_G.dd = function(...)
  require("util").dump(...)
end
_G.bt = function(...)
  require("util").bt(...)
end

vim.print = _G.dd
_G.lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.cmd([[
  nmap > [
  nmap < ]
  omap > [
  omap < ]
  xmap > [
  xmap < ]
]])

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.keymaps")
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
