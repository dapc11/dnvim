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

function _G.map(mode, lhs, rhs, opts)
	opts = opts or {}
	local r, o = map_utils(rhs, opts)
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
