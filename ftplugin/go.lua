local bufnr = vim.api.nvim_get_current_buf()

-- vim.keymap.set("n", "gf", "", { desc = "Find Usages", buffer = bufnr })
vim.keymap.set(
  "n",
  "<leader>tq",
  "<cmd>Dispatch gotestsum --format pkgname-and-test-fails --no-summary=output,skipped --format-hide-empty-pkg<cr>",
  { desc = "Dispatch tests", buffer = bufnr }
)
