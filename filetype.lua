vim.filetype.add({
	extension = {
		tpl = "gotmpl",
	},
	pattern = {
		[".*/templates/.*tpl"] = "gotmpl",
		[".*/templates/.*yaml"] = "gotmpl",
		[".*/templates/.*.yml"] = "gotmpl",
	},
})
