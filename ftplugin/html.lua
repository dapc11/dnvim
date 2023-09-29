local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n",
  "gd",
  "<cmd>!firefox %<cr><cr> <BAR> <cmd>b#<cr>",
  { desc = "Open in Firefox", buffer = bufnr, silent = true }
)
