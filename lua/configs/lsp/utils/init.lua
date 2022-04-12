local status_ok, lspsignature = pcall(require, "lsp_signature")
if not status_ok then
	error("Failed loading lsp_signature")
	return
end
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
	error("Failed loading cmp_nvim_lsp")
	return
end

local M = {}

M.diagnostics_config = {
	virtual_text = false,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "single",
		source = "always",
		header = "",
		prefix = "",
	},
}

M.handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "single",
		scope = "line",
	}),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "single",
		scope = "line",
	}),
}

function M.lsp_keymaps(bufnr)
	local opts = {}
	bmap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	bmap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	bmap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	bmap(bufnr, "n", "ge", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	bmap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	bmap(bufnr, "n", "<space>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
	bmap(bufnr, "n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	bmap(bufnr, "n", "<C-b>", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	bmap(bufnr, "n", "<C-n>", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
end

function M.lsp_highlight_document(client)
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

function M.lsp_signature(bufnr)
	lspsignature.on_attach({
		bind = true, -- This is mandatory, otherwise border config won"t get registered.
		handler_opts = {
			border = "single",
		},
		hint_prefix = " ",
		max_height = 8,
	}, bufnr)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities)
M.flags = {
	debounce_text_changes = 150,
}

return M