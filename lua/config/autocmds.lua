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
  pattern = "fugitiveblame",
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.cursorline = false
    vim.opt_local.signcolumn = "no"
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.wo[win].scrollbind and vim.bo[buf].filetype ~= "fugitiveblame" then
        vim.wo[win].cursorline = false
        vim.wo[win].relativenumber = false
        vim.wo[win].signcolumn = "no"
      end
    end
  end,
})

vim.g.fugitive_dynamic_colors = 0

-- Prevent treesitter from repeatedly scanning for a non-existent fugitiveblame parser
vim.treesitter.language.register("bash", "fugitiveblame")

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

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(ev)
    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local has_conflict = false
    for _, l in ipairs(lines) do
      if l:find("^<<<<<<< ") then has_conflict = true break end
    end
    if not has_conflict then return end

    local function keep_side(ours)
      local cur = vim.api.nvim_win_get_cursor(0)[1]
      -- find conflict boundaries around cursor
      local start, mid, sep, finish
      for i = cur, 1, -1 do
        if vim.fn.getline(i):find("^<<<<<<< ") then start = i break end
      end
      if not start then vim.notify("No conflict block found", vim.log.levels.WARN) return end
      for i = start + 1, vim.fn.line("$") do
        local ln = vim.fn.getline(i)
        if ln:find("^||||||| ") then mid = i
        elseif ln:find("^=======$") then sep = i
        elseif ln:find("^>>>>>>> ") then finish = i break end
      end
      if not sep or not finish then return end
      -- delete markers and unwanted side
      local del = {}
      if ours then
        -- keep lines between start and (mid or sep), delete rest
        if mid then for i = mid, finish do del[#del + 1] = i end
        else for i = sep, finish do del[#del + 1] = i end end
        del[#del + 1] = start
      else
        -- keep lines between sep and finish, delete rest
        del[#del + 1] = finish
        if mid then for i = start, sep do del[#del + 1] = i end
        else for i = start, sep do del[#del + 1] = i end end
      end
      table.sort(del, function(a, b) return a > b end)
      local seen = {}
      for _, i in ipairs(del) do
        if not seen[i] then vim.api.nvim_buf_set_lines(0, i - 1, i, false, {}) seen[i] = true end
      end
    end

    map("n", "<leader><left>", function() keep_side(true) end, { buffer = ev.buf, silent = true, desc = "Keep ours" })
    map("n", "<leader><right>", function() keep_side(false) end, { buffer = ev.buf, silent = true, desc = "Keep theirs" })
    map("n", "<leader><up>", function() vim.fn.search("^<<<<<<< ", "bw") end, { buffer = ev.buf, silent = true, desc = "Prev conflict" })
    map("n", "<leader><down>", function() vim.fn.search("^<<<<<<< ", "w") end, { buffer = ev.buf, silent = true, desc = "Next conflict" })
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
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})
