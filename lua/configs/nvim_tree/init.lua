local M = {}
function M.config()
	vim.g.nvim_tree_highlight_opened_files = 1
	vim.g.nvim_tree_root_folder_modifier = table.concat({ ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" })

	vim.g.nvim_tree_respect_buf_cwd = 1
	vim.g.nvim_tree_show_icons = {
		git = 0,
		folder_arrows = 0,
		folders = 1,
		files = 0,
	}
	vim.g.nvim_tree_icons = {
		default = "",
		symlink = "",
		git = {
			unstaged = "",
			staged = "S",
			unmerged = "",
			renamed = "➜",
			deleted = "",
			untracked = "U",
			ignored = "◌",
		},
		folder = {
			arrow_open = "",
			arrow_closed = "",
			default = "",
			open = "",
			empty = "", -- 
			empty_open = "",
			symlink = "",
			symlink_open = "",
		},
	}

	require("nvim-tree").setup({
		disable_netrw = false,
		hijack_netrw = false,
		ignore_ft_on_setup = { "dashboard" },
		auto_close = false,
		open_on_tab = false,
		hijack_cursor = true,
		update_cwd = true,
		update_focused_file = {
			enable = true,
			update_cwd = true,
			ignore_list = { "**/.git" },
		},
		renderer = {
			indent_markers = {
				enable = true,
			},
		},
		git = {
			enable = false,
			ignore = false,
			timeout = 500,
		},
		filters = {
			dotfiles = false,
			custom = { ".git" },
		},
		diagnostics = {
			enable = false,
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		view = {
			width = 30,
			side = "left",
			auto_resize = true,
			mappings = {
				custom_only = false,
				list = {
					{ key = "<C-t>", action = "" },
				},
			},
		},
	})
end

return M
