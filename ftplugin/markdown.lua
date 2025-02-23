vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Preview a Linked Note", buffer = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set(
  "n",
  "<leader>zL",
  vim.cmd.ZkBacklinks,
  { desc = "Open Notes Linking to Buffer", buffer = true }
)
vim.keymap.set("n", "<leader>zf", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set(
  { "v", "n" },
  "<leader>zl",
  vim.cmd.ZkLinks,
  { desc = "Open Notes Linked by the Buffer", buffer = true }
)
vim.opt_local.wrap = true
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

vim.cmd([[
au FileType markdown setl comments=b:*,b:-,b:+,n:>
au FileType markdown setl formatoptions+=r
]])
