local utils = require("core.utils")

utils.disabled_builtins()

utils.bootstrap()

utils.impatient()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/lua/configs/lsp/?/init.lua"

local sources = { "core.globals", "core.plugins", "core.options", "core.keymaps", "core.custom-theme" }

for _, source in ipairs(sources) do
  local ok, err_msg = pcall(require, source)
  if not ok then
    error("Failed to load " .. source .. "\n\n" .. err_msg)
  end
end

map("n", "<", "]", { noremap = false })
map("o", "<", "]", { noremap = false })
map("x", "<", "]", { noremap = false })
map("n", ">", "[", { noremap = false })
map("o", ">", "[", { noremap = false })
map("x", ">", "[", { noremap = false })

utils.compiled()
