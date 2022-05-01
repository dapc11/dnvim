local M = {}
function M.config()
	require("project_nvim").setup({
		-- Manual mode doesn't automatically change your root directory, so you have
		-- the option to manually do so using `:ProjectRoot` command.
		manual_mode = false,

		-- Methods of detecting the root directory. **"lsp"** uses the native neovim
		-- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
		-- order matters: if one is not detected, the other is used as fallback. You
		-- can also delete or rearangne the detection methods.
		detection_methods = { "pattern" },

		-- All the patterns used to detect root dir, when **"pattern"** is in
		-- detection_methods
		patterns = {
			"ruleset2.0.yaml",
			"pom.xml",
			".git",
			"_darcs",
			".hg",
			".bzr",
			".svn",
			"Makefile",
			"package.json",
		},

		-- Table of lsp clients to ignore by name
		-- eg: { "efm", ... }
		ignore_lsp = { "pyright", "sumneko_lua", "null-ls", "gopls", "yamlls" },

		-- When set to false, you will get a message when project.nvim changes your
		-- directory.
		silent_chdir = true,
	})
end
return M
