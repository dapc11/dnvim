local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n",
  "gd",
  "<cmd>!firefox %<CR><CR> <BAR> <cmd>b#<CR>",
  { desc = "Open in Firefox", buffer = bufnr, silent = true }
)
