vim.keymap.set(
  { "v", "n" },
  "<leader>cF",
  ":%!jq -R -r '. as $line | try fromjson catch $line'<CR>",
  { desc = "Format", buffer = true }
)
vim.keymap.set(
  "n",
  "<leader>cl",
  ":%!jq -R -r '. as $line | try fromjson catch $line | \"\\(.timestamp)\t\\(.severity)\t\\(.message)\"'<CR>",
  { desc = "Make logs readable", buffer = true }
)

