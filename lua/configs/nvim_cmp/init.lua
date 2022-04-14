local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").load()
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"

local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "ﰠ",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "פּ",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local mapping = {
	["<C-d>"] = cmp.mapping.scroll_docs(-4),
	["<C-f>"] = cmp.mapping.scroll_docs(4),
	["<C-e>"] = cmp.mapping({
		i = cmp.mapping.abort(),
		c = cmp.mapping.close(),
	}),
	["<CR>"] = cmp.mapping({
		i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
		c = function(fallback)
			if cmp.visible() then
				cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
			else
				fallback()
			end
		end,
	}),
	["<Tab>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_next_item()
		elseif luasnip.expand_or_jumpable() then
			luasnip.expand_or_jump()
		elseif has_words_before() then
			cmp.complete()
		else
			fallback()
		end
	end, { "i", "s" }),
	["<S-Tab>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_prev_item()
		elseif luasnip.jumpable(-1) then
			luasnip.jump(-1)
		else
			fallback()
		end
	end, { "i", "s" }),
	["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
	["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
	["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
}

cmp.setup({
	completion = { completeopt = "menu,menuone,noinsert" },
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = mapping,
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 2 },
		{ name = "luasnip" },
		{ name = "path", max_item_count = 10 },
	},
	formatting = {
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
			-- Source
			-- vim_item.menu = ({
			-- 	buffer = "[Buf]",
			-- 	nvim_lsp = "[LSP]",
			-- 	luasnip = "[Snip]",
			-- 	path = "[Path]",
			-- })[entry.source.name]
			return vim_item
		end,
	},
	window = {
		completion = {
			border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
		},
		documentation = {
			border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
		},
	},
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won"t work anymore).
cmp.setup.cmdline("/", {
	mapping = mapping,
	sources = {
		{ name = "buffer", keyword_length = 2 },
	},
})
cmp.setup.cmdline(":", {
	mapping = mapping,
	sources = {
		{ name = "path", keyword_length = 2 },
		{ name = "cmdline", keyword_length = 2, keyword_pattern = [=[[^[:blank:]\!]*]=] },
	},
})
cmp.setup.filetype({ "gitcommit", "fugitive" }, {
	sources = {
		{ name = "buffer" },
		{ name = "path" },
	},
})
