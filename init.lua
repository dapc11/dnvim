_G.lazyfile = { "BufReadPost", "BufNewFile" }

-- TODO(nvim-0.12): Remove when bundled markdown parser is fixed.
-- The bundled parser (Jul 2024) produces invalid TSNode objects missing the
-- :range() method, crashing languagetree.lua during injection processing.
do
  local ts = vim.treesitter
  local orig = ts.get_range
  ts.get_range = function(node, source, metadata)
    if not node or not node.range then
      return { 0, 0, 0, 0, 0, 0 }
    end
    return orig(node, source, metadata)
  end
end

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.usercmds")
require("config.keymaps")
require("config.lsp")
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
require("user.dashboard")
