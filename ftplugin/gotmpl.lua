local bufnr = vim.api.nvim_get_current_buf()
GetVisualSelection = require("util.common").GetVisualSelection

vim.keymap.set(
  "n",
  "gf",
  '"vyi"<cmd>lua require("telescope.builtin").live_grep({ default_text = GetVisualSelection() })<cr>',
  { desc = "Find Usages", buffer = bufnr }
)
