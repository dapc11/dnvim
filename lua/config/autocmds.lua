local function close_buffer()
  if vim.fn.winnr("$") == 1 then
    Snacks.dashboard()
  else
    vim.cmd.close()
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = require("util.common").ignored_filetypes,
  callback = function(event)
    local buf_ft = vim.bo.filetype
    if buf_ft ~= "oil" then
      vim.keymap.set("n", "q", close_buffer, { silent = true, buffer = true })
      vim.keymap.set("n", "<esc>", close_buffer, { silent = true, buffer = true })
      vim.keymap.set("n", "<c-c>", close_buffer, { silent = true, buffer = true })
    end
    vim.bo[event.buf].buflisted = false
    vim.opt.colorcolumn = "0"
    vim.keymap.set("n", "<c-j>", "j<CR>", { silent = true, buffer = true })
    vim.keymap.set("n", "<c-k>", "k<CR>", { silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(event)
    if vim.fn.search("<<<<<<< Updated upstream", "nw") ~= 0 then
      vim.diagnostic.disable(event.buf)
      vim.cmd([[
nnoremap <buffer> <silent> <leader>h2 :diffget //2<Bar>diffupdate<CR>
nnoremap <buffer> <silent> <leader>h3 :diffget //3<Bar>diffupdate<CR>
      ]])
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
    vim.keymap.set("n", "<c-c><c-c>", "<cmd>wq<CR>", { noremap = true, buffer = true })
    vim.keymap.set("i", "<c-c><c-c>", "<esc><cmd>wq<CR>", { noremap = true, buffer = true })
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
