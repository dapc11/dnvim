vim.filetype.add({
	extension = {
		tpl = "gotmpl",
		yml = function(path, bufnr)
			if vim.fn.search("{{-.*}}", "nw") ~= 0 or vim.fn.search("{{.*include.*}}") ~= 0 then
				return "gotmpl"
			end
			return "yaml"
		end,
		yaml = function(path, bufnr)
			if vim.fn.search("{{-.*}}", "nw") ~= 0 or vim.fn.search("{{.*include.*}}") ~= 0 then
				return "gotmpl"
			end
			return "yaml"
		end,
	},
	pattern = {
		[".*/templates/.*tpl"] = "gotmpl",
		[".*/templates/.*yaml"] = "gotmpl",
		[".*/templates/.*yml"] = "gotmpl",
	},
})
