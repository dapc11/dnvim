local treesitter = require("nvim-treesitter.configs")
require("tsht").config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

local disable_large_files = function(_, bufnr)
	return vim.api.nvim_buf_line_count(bufnr) > 1000
end

parser_config.gotmpl = {
	install_info = {
		url = "https://github.com/ngalaiko/tree-sitter-go-template",
		files = { "src/parser.c" },
	},
	filetype = "gotmpl",
	used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml", "tpl" },
}
treesitter.setup({
	ensure_installed = {
		"python",
		"lua",
		"dockerfile",
		"json",
		"yaml",
		"css",
		"html",
		"go",
		"bash",
		"java",
		"vim",
		"toml",
		"markdown",
	},
	highlight = {
		enable = true,
		disable = disable_large_files,
		-- additional_vim_regex_highlighting = { "python" }
	},
	incremental_selection = {
		enable = true,
	},
	textobjects = {
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
		disable = disable_large_files,
	},
	autotag = {
		enable = true,
		filetypes = { "html", "xml" },
	},
	refactor = {
		highlight_definitions = {
			enable = true,
			disable = disable_large_files,
		},
		highlight_current_scope = {
			enable = false,
			disable = disable_large_files,
		},
		smart_rename = {
			enable = true,
			disable = disable_large_files,
			keymaps = {
				smart_rename = "<Space>rr",
			},
		},
	},
	pairs = {
		enable = true,
		disable = {},
		highlight_pair_events = {}, -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
		highlight_self = false, -- whether to highlight also the part of the pair under cursor (or only the partner)
		goto_right_end = false, -- whether to go to the end of the right partner or the beginning
		fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
		keymaps = { goto_partner = "<leader>%" }, -- do not work
	},
})