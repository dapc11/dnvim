vim.keymap.set(
  "n",
  "gd",
  "<cmd>!firefox %<CR><CR> <BAR> <cmd>b#<CR>",
  { desc = "Open in Firefox", buffer = true, silent = true }
)
