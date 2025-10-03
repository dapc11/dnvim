vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Preview a Linked Note", buffer = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set("n", "<leader>zL", vim.cmd.ZkBacklinks, { desc = "Open Notes Linking to Buffer", buffer = true })
vim.keymap.set("n", "<leader>zf", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set({ "v", "n" }, "<leader>zl", vim.cmd.ZkLinks, { desc = "Open Notes Linked by the Buffer", buffer = true })
vim.opt_local.wrap = true
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

vim.cmd([[
au FileType markdown setl comments=b:*,b:-,b:+,n:>
au FileType markdown setl formatoptions+=r
]])

vim.opt_local.colorcolumn = "100"


vim.api.nvim_create_user_command("VALint", function()
  local file = vim.fn.expand("%")
  local cmd = "~/repos_personal/va_report_linter/va_linter.py " .. vim.fn.shellescape(file)
  vim.fn.setqflist({}, "r", { lines = vim.fn.systemlist(cmd) })
  vim.cmd("copen")
end, {})
vim.keymap.set("n",
  "<leader>cl",
  "<cmd>VALint<cr>", { desc = "Lint", buffer = true })


vim.keymap.set("n", "gj", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })
vim.keymap.set("n", "gd", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })
