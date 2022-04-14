local function map_utils(rhs, opts)
	local callback = nil
	if type(rhs) ~= "string" then
		callback = rhs
	end

	opts = vim.tbl_extend("keep", opts, {
		noremap = true,
		silent = true,
		expr = false,
		callback = callback,
	})
	return rhs, opts
end

local wk = require("which-key")
function _G.map(mode, lhs, rhs, opts)
	opts = opts or {}
	local r, o = map_utils(rhs, opts)
	--     {
	--   mode = "n", -- NORMAL mode
	--   -- prefix: use "<leader>f" for example for mapping everything related to finding files
	--   -- the prefix is prepended to every mapping part of `mappings`
	--   prefix = "",
	--   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	--   silent = true, -- use `silent` when creating keymaps
	--   noremap = true, -- use `noremap` when creating keymaps
	--   nowait = false, -- use `nowait` when creating keymaps
	-- }
	wk.register(mappings, {
		mode = mode,
		prefix = "",
		buffer = nil,
		silent = opts.silent,
		noremap = opts.noremap,
		nowait = opts.nowait,
	})
	vim.api.nvim_set_keymap(mode, lhs, r, o)
end

function _G.bmap(bufnr, mode, lhs, rhs, opts)
	opts = opts or {}
	local r, o = map_utils(rhs, opts)
	vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, r, o)
end

function _G.au(event, filetype, action)
	vim.cmd("au" .. " " .. event .. " " .. filetype .. " " .. action)
end

function _G.hi(group, options)
	vim.cmd(
		"hi "
			.. group
			.. " "
			.. "cterm="
			.. (options.cterm or "none")
			.. " "
			.. "ctermfg="
			.. (options.ctermfg or "none")
			.. " "
			.. "ctermbg="
			.. (options.ctermbg or "none")
			.. " "
			.. "gui="
			.. (options.gui or "none")
			.. " "
			.. "guifg="
			.. (options.guifg or "none")
			.. " "
			.. "guibg="
			.. (options.guibg or "none")
	)
end
