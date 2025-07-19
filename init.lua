local events = require("config.events")
_G.lazyfile = events.lazy_file_events

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("config.lazy")()
-- require("config.theme")
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lsp")
require("config.jdtls")
require("config.supertab").setup()
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
