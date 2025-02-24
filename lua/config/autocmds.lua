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
    if vim.fn.search("<<<<<<< HEAD", "nw") ~= 0 then
      vim.diagnostic.disable(event.buf)
      map("n", "<leader><left>", function()
        vim.cmd.diffget("//2")
        vim.cmd("diffupdate")
      end, { buffer = true, silent = true, desc = "Ours" })
      map("n", "<leader><right>", function()
        vim.cmd.diffget("//3")
        vim.cmd("diffupdate")
      end, { buffer = true, silent = true, desc = "Theirs" })
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 50 })
  end,
})

local matches = {}
vim.api.nvim_create_autocmd("User", {
  callback = function(event)
    local ident = vim.fn.win_getid()
    local match = matches[ident]
    if vim.tbl_contains(require("util.common").ignored_filetypes, vim.bo[event.buf].filetype) then
      if match ~= nil then
        pcall(vim.fn.matchdelete, match)
        matches[ident] = nil
      end
    else
      if match == nil then
        matches[ident] = vim.fn.matchadd("@diff.minus", "\\v((.*%#)@!|%#)\\s+$")
      end
    end
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

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
