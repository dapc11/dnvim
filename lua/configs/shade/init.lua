local M = {}

function M.config()
	require("shade").setup({
		overlay_opacity = 80,
		opacity_step = 1,
		keys = {
			toggle = "<Leader>zs",
		},
	})
end

return M
