local map = require("util").map

local function close_buffer()
  if vim.fn.winnr("$") == 1 then
    Snacks.dashboard()
  else
    pcall(vim.cmd.close)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = require("util.common").ignored_filetypes,
  callback = function(event)
    local buf_ft = vim.bo.filetype
    if buf_ft ~= "oil" then
      map("n", "q", close_buffer, { silent = true, buffer = true })
      map("n", "<esc>", close_buffer, { silent = true, buffer = true })
      map("n", "<c-c>", close_buffer, { silent = true, buffer = true })
    end
    vim.bo[event.buf].buflisted = false
    vim.opt.colorcolumn = "0"
    map("n", "<c-j>", "j<CR>", { silent = true, buffer = true })
    map("n", "<c-k>", "k<CR>", { silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(event)
    if vim.fn.search("<<<<<<< Updated upstream", "nw") ~= 0 then
      vim.diagnostic.disable(event.buf)
      map("n", "<leader>h2", "<cmd>diffget //2<bar>diffuppdate<cr>", { buffer = true, silent = true })
      map("n", "<leader>h3", "<cmd>diffget //3<bar>diffuppdate<cr>", { buffer = true, silent = true })
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 50 })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "COMMIT_EDITMSG",
  callback = function()
    map("n", "<c-g><c-g>", "<cmd>wq<CR>", { noremap = true, buffer = true })
    map("i", "<c-g><c-g>", "<C-c><cmd>wq<CR>", { noremap = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local dir = require("util.init").get_project_root(".git")
    if dir ~= nil then
      vim.cmd("cd " .. dir)
    end
  end,
})

-- always open quickfix window automatically.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
  pattern = { "[^l]*" },
  command = "cwindow",
})
