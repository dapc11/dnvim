_G.lazyfile = { "BufReadPost", "BufNewFile" }

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.usercmds")
require("config.keymaps")
require("config.lsp")
require("config.jdtls")
require("config.amazonq")
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
