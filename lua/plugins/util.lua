local function findTerminal()
  local bufIds = vim.api.nvim_list_bufs()
  for _, x in pairs(bufIds) do
    if string.find(vim.api.nvim_buf_get_name(x), "term") then
      return x
    end
  end
  return nil
end

local function openTerminal(direction)
  vim.cmd(direction)
  vim.cmd("wincmd l")
  local currentTerminal = findTerminal()

  if currentTerminal ~= nil then
    vim.cmd("buf " .. currentTerminal)
  else
    vim.cmd("term")
  end

  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>xv", function()
  openTerminal("vsplit")
end, { desc = "Vsplit Term" })
vim.keymap.set("n", "<leader>x-", function()
  openTerminal("split")
end, { desc = "Split Term" })
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-d>", "<C-\\><C-n>:q<CR>")
return {}
