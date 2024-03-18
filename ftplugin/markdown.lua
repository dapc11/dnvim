local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Preview a Linked Note", buffer = bufnr })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Follow Link", buffer = bufnr })
vim.keymap.set("n", "<leader>zL", vim.cmd.ZkBacklinks, { desc = "Open Notes Linking to Buffer", buffer = bufnr })
vim.keymap.set("n", "<leader>zf", vim.lsp.buf.definition, { desc = "Follow Link", buffer = bufnr })
vim.keymap.set(
  "v",
  "<leader>za",
  ":'<,'>lua vim.lsp.buf.range_code_action()<CR>",
  { desc = "Code Actions", buffer = bufnr }
)
vim.keymap.set(
  { "v", "n" },
  "<leader>zl",
  vim.cmd.ZkLinks,
  { desc = "Open Notes Linked by the Buffer", buffer = bufnr }
)
vim.cmd([[
setlocal wrap spell spelllang=en_us
" au FileType markdown setl comments=b:*,b:-,b:+,n:>
" au FileType markdown setl formatoptions+=r
]])
