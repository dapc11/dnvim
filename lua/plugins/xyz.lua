local function findTerminal()
  for _, bufId in pairs(vim.api.nvim_list_bufs()) do
    if string.find(vim.api.nvim_buf_get_name(bufId), "term://") then
      return bufId
    end
  end
  return nil
end

local function openTerminal(direction)
  local currentTerminal = findTerminal()
  if currentTerminal ~= nil then
    vim.cmd("wincmd j")
    vim.cmd("buf " .. currentTerminal)
  else
    vim.cmd(direction)
    vim.cmd("wincmd l")
    vim.print(currentTerminal)
    vim.cmd.terminal({ "zsh" })
  end

  vim.cmd("startinsert")
end

local map = require("util").map

-- stylua: ignore start
map("n", "<leader>xv", function() openTerminal("vsplit") end, { desc = "Vsplit Term" })
map("n", "<leader>x-", function() openTerminal("split") end, { desc = "Split Term" })
map("t", "<esc>", "<C-\\><C-n>")
map("t", "<C-q>", "<C-\\><C-n>")
map("t", "<C-x>", "<C-\\><C-n>:q<CR>")
map("t", "<C-d>", "<C-\\><C-n>:q<CR>")
-- stylua: ignore end
return {}
