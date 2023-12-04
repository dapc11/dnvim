local bufnr = vim.api.nvim_get_current_buf()
GetVisualSelection = require("util.common").GetVisualSelection

vim.keymap.set("n", "gf", function()
  vim.api.nvim_exec("tab Git show " .. vim.call("expand", "<cword>"), true)
end, { desc = "Find Usages", buffer = bufnr })
-- 'viw<cmd>lua vim.cmd.Git({"show " .. GetVisualSelection() })<cr>',
