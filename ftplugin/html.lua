vim.keymap.set(
  "n",
  "gd",
  "<cmd>!google-chrome %<CR><CR> <BAR> <cmd>b#<CR>",
  { desc = "Open in Chrome", buffer = true, silent = true }
)
