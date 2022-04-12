------ Setup formatting.
local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
	return
end

local lsputils = require('utils')

local write_good = null_ls.builtins.diagnostics.write_good.with({
	filetypes = { "markdown", "gitcommit", "text" },
})
local black = null_ls.builtins.formatting.black
local pylint = null_ls.builtins.diagnostics.pylint.with({
	filetypes = { "python" },
	extra_args = {
		"-d",
		"R0801,W1508,C0114,C0115,C0116,C0301,W0611,W1309",
	},
})
local flake8 = null_ls.builtins.diagnostics.flake8.with({
	filetypes = { "python" },
	extra_args = {
		"--per-file-ignores=**/test_*:D100,D103",
	},
})
local isort = null_ls.builtins.formatting.isort
local gofmt = null_ls.builtins.formatting.gofmt
local goimports = null_ls.builtins.formatting.goimports
local stylua = null_ls.builtins.formatting.stylua

-- register any number of sources simultaneously
local sources = {
	null_ls.builtins.diagnostics.trail_space,
	null_ls.builtins.code_actions.gitsigns,
	stylua,
	black,
	gofmt,
	goimports,
	write_good,
	pylint,
	flake8,
	null_ls.builtins.diagnostics.golangci_lint,
}

vim.diagnostic.config(lsputils.diagnostics_config)

null_ls.setup({
	sources = sources,
	diagnostics_format = "[#{c}] #{m}",
	handlers = lsputils.handlers,
	on_attach = function(client, bufnr)
		if client.resolved_capabilities.document_formatting then
			vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
		end
		lsputils.lsp_keymaps(bufnr)
		lsputils.lsp_signature(bufnr)
	end,
})