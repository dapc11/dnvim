local ignored_filetypes = require("util").ignored_filetypes

local map = require("util").map

local function close_buffer()
  if vim.fn.winnr("$") == 1 then
    require("user.dashboard").open()
  else
    pcall(vim.cmd.close)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = ignored_filetypes,
  callback = function(event)
    local buf_ft = vim.bo.filetype
    if buf_ft ~= "oil" then
      map("n", "q", close_buffer, { silent = true, buffer = true })
      -- map("n", "<esc>", close_buffer, { silent = true, buffer = true })
      map("n", "<c-c>", close_buffer, { silent = true, buffer = true })
    end
    vim.bo[event.buf].buflisted = false
    vim.opt.colorcolumn = "0"
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(_)
    if vim.fn.search("<<<<<<< HEAD", "nw") ~= 0 then
      map("n", "<leader><left>", function()
        vim.cmd.diffget("//2")
        vim.cmd("diffupdate")
      end, { buffer = true, silent = true, desc = "Ours" })
      map("n", "<leader><right>", function()
        vim.cmd.diffget("//3")
        vim.cmd("diffupdate")
      end, { buffer = true, silent = true, desc = "Theirs" })
      map("n", "<leader><up>", function()
        vim.fn.search("<<<<<<< HEAD", "bw")
      end, { buffer = true, silent = true, desc = "Previous conflict" })
      map("n", "<leader><down>", function()
        vim.fn.search("<<<<<<< HEAD", "w")
      end, { buffer = true, silent = true, desc = "Next conflict" })
    end
  end,
})

local skip_fts = {}
for _, ft in ipairs(ignored_filetypes) do skip_fts[ft] = true end
for _, ft in ipairs({ "toggleterm", "fzf", "blink-cmp-menu" }) do skip_fts[ft] = true end

local matches = {}
vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#FF5555" }) -- Red background
local function update_match(event)
  local buf = event.buf
  local win_id = vim.api.nvim_get_current_win()

  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype
  local match = matches[win_id]

  -- Skip floating windows, terminal buffers, or ignored filetypes
  local cfg = vim.api.nvim_win_get_config(win_id)
  if cfg.relative ~= "" or buftype == "terminal" or skip_fts[filetype] then
    if match then
      pcall(vim.fn.matchdelete, match)
      matches[win_id] = nil
    end
    return
  end

  if not match then
    matches[win_id] = vim.fn.matchadd("TrailingWhitespace", "\\v\\s+$")
  end
end

-- Run when switching windows or exiting Insert mode
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "WinEnter", "InsertLeave", "BufReadPost", "FileType" }, {
  callback = update_match,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local dir = require("util").get_project_root(".git")
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

-- Auto save when losing focus
vim.api.nvim_create_autocmd("FocusLost", {
  group = vim.api.nvim_create_augroup("auto_save", { clear = true }),
  callback = function()
    vim.cmd("silent! wa")
  end,
})

vim.api.nvim_create_user_command("GremoveConflictMarkers", function(opts)
  vim.cmd(opts.line1 .. "," .. opts.line2 .. [[g/^\(<\{7}\||\{7}\|=\{7}\|>\{7}\)/d]])
end, { range = "%" })
