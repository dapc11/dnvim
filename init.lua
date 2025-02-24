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

_G.lazyfile = { "BufReadPost", "BufNewFile" }

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.jdtls")
if vim.g.neovide then
  require("config.neovide")
end
require("util.profile")
