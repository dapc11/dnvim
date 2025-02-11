_G.dd = function(...)
  require("util").dump(...)
end
_G.bt = function(...)
  require("util").bt(...)
end

_G.python_format = true
_G.lua_format = true
_G.go_format = true

vim.print = _G.dd
vim.dump = function(tbl, indent)
  if not indent then
    indent = 2
  end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      vim.dump(v, indent + 1)
    elseif type(v) == "boolean" then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end
_G.lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.cmd([[
  nmap > [
  nmap < ]
  omap > [
  omap < ]
  xmap > [
  xmap < ]

setglobal grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ \ %l%m
if executable('ag')
  setglobal grepprg=ag\ -s\ --vimgrep
elseif has('unix')
  setglobal grepprg=grep\ -rn\ $*\ /dev/null
endif

]])

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.jdtls")
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
