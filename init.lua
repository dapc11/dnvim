local utils = require("core.utils")

utils.disabled_builtins()

utils.bootstrap()

utils.impatient()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/lua/configs/lsp/?/init.lua"

-- Disable plugins
_G.plugins = {}
_G.plugins.hop = false

local sources = {
  "core.globals",
  "core.plugins",
  "core.options",
  "core.autocommands",
  "core.keymaps",
  "core.custom-theme",
}

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
-- vim.api.nvim_command([[autocmd CursorHold   * lua require'core.utils'.blameVirtText()]])
-- vim.api.nvim_command([[autocmd CursorMoved  * lua require'core.utils'.clearBlameVirtText()]])
-- vim.api.nvim_command([[autocmd CursorMovedI * lua require'core.utils'.clearBlameVirtText()]])
--
-- vim.cmd([[
--     hi! link GitLens Comment
-- ]])
utils.compiled()
