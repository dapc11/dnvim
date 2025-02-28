local bufnr = vim.api.nvim_get_current_buf()
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  buffer = bufnr,
  callback = function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end,
})
