vim.opt.list = true
vim.g.indent_blankline_filetype_exclude = { "NvimTree", "packer" }
vim.cmd([[highlight IndentBlanklineChar guifg=#3e4451 gui=nocombine]])

require("indent_blankline").setup({
	show_end_of_line = false,
	space_char_blankline = " ",
})
