local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set({ "v", "n" }, "<leader>cf", ":%!jq '.'", { desc = "Format", buffer = bufnr })
vim.keymap.set(
  "n",
  "<leader>cl",
  ":%!jq -r '\"\\(.timestamp)\t\\(.severity)\t\\(.message)\"'<CR>",
  { desc = "Make logs readable", buffer = bufnr }
)
