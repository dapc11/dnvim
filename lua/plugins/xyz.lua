local function openTerminal(direction)
  vim.cmd(direction)
  vim.cmd("wincmd l")
  vim.cmd.edit({ "term://zsh" })
  vim.cmd("startinsert")
end

local map = require("util").map

map("n", "<leader>xv", function()
  openTerminal("vsplit")
end, { desc = "Vsplit Term" })
map("n", "<leader>x-", function()
  openTerminal("split")
end, { desc = "Split Term" })
map("t", "<esc>", "<C-\\><C-n>")
map("t", "<C-q>", "<C-\\><C-n>")
map("t", "<C-x>", "<C-\\><C-n>:q<CR>")
map("t", "<C-d>", "<C-\\><C-n>:q<CR>")
return {}
