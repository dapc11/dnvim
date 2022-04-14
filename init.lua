local utils = require("core.utils")

utils.disabled_builtins()

utils.bootstrap()

utils.impatient()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/lua/configs/lsp/?/init.lua"

local sources = { "core.globals", "core.plugins", "core.options", "core.keymaps", "core.custom-theme" }

for _, source in ipairs(sources) do
	local status_ok, fault = pcall(require, source)
	if not status_ok then
		error("Failed to load " .. source .. "\n\n" .. fault)
	end
end

utils.compiled()
