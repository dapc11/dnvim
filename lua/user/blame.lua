local M = {}

---@class BlameEntry
---@field hash string
---@field orig_line number
---@field author string
---@field date string
---@field filename string

---@class BlameState
---@field source_buf number
---@field source_win number
---@field blame_buf number
---@field blame_win number
---@field entries BlameEntry[]
---@field autocmd_ids number[]
---@field history table[] -- stack of {commit, file, line} for navigating back

local state = nil

local function hash_to_color(hash)
  local r = tonumber(hash:sub(1, 2), 16)
  local g = tonumber(hash:sub(3, 4), 16)
  local b = tonumber(hash:sub(5, 6), 16)
  r = math.floor(r * 3 / 4 + 32)
  g = math.floor(g * 3 / 4 + 32)
  b = math.floor(b * 3 / 4 + 32)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function get_or_create_hl(hash)
  if hash:match("^0+$") then return "Comment" end
  local hl_name = "BlameHash_" .. hash:sub(1, 6)
  if vim.fn.hlexists(hl_name) == 0 then
    vim.api.nvim_set_hl(0, hl_name, { fg = hash_to_color(hash:sub(1, 6)) })
  end
  return hl_name
end

---Parse `git blame --porcelain` output
---@param output string
---@param total_lines number
---@return BlameEntry[]
local function parse_porcelain(output, total_lines)
  local entries = {}
  local current = {}
  local hash_data = {} -- cache per-hash metadata
  for line in output:gmatch("[^\n]+") do
    local hash, orig, final = line:match("^(%x+) (%d+) (%d+)")
    if hash then
      current = { hash = hash, orig_line = tonumber(orig) }
      -- Inherit cached data from previous occurrence of same hash
      if hash_data[hash] then
        current.author = hash_data[hash].author
        current.date = hash_data[hash].date
        current.filename = hash_data[hash].filename
      end
      entries[tonumber(final)] = current
    elseif line:match("^author ") then
      current.author = line:sub(8)
      if current.hash then hash_data[current.hash] = hash_data[current.hash] or {}; hash_data[current.hash].author = current.author end
    elseif line:match("^author%-time ") then
      current.date = os.date("%Y-%m-%d", tonumber(line:sub(13)))
      if current.hash then hash_data[current.hash] = hash_data[current.hash] or {}; hash_data[current.hash].date = current.date end
    elseif line:match("^filename ") then
      current.filename = line:sub(10)
      if current.hash then hash_data[current.hash] = hash_data[current.hash] or {}; hash_data[current.hash].filename = current.filename end
    end
  end
  return entries
end

---@param entries BlameEntry[]
---@param total_lines number
---@return string[], number
local function format_entries(entries, total_lines)
  local lines = {}
  local max_width = 0
  for i = 1, total_lines do
    local e = entries[i]
    local text
    if e then
      text = string.format("%.8s %s %-12s", e.hash, e.date, e.author or "")
    else
      text = ""
    end
    lines[i] = text
    if #text > max_width then max_width = #text end
  end
  return lines, max_width
end

local function sync_cursor(source_to_blame)
  if not state then return end
  if not vim.api.nvim_win_is_valid(state.source_win) or not vim.api.nvim_win_is_valid(state.blame_win) then return end

  local from_win = source_to_blame and state.source_win or state.blame_win
  local to_win = source_to_blame and state.blame_win or state.source_win
  local line = vim.api.nvim_win_get_cursor(from_win)[1]
  local to_line = vim.api.nvim_win_get_cursor(to_win)[1]
  if line == to_line then return end
  pcall(vim.api.nvim_win_set_cursor, to_win, { line, 0 })

  -- Sync topline
  local from_top = vim.api.nvim_win_call(from_win, function() return vim.fn.winsaveview().topline end)
  vim.api.nvim_win_call(to_win, function() vim.fn.winrestview({ topline = from_top }) end)
end

local function close_blame()
  if not state then return end
  for _, id in ipairs(state.autocmd_ids) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  if vim.api.nvim_win_is_valid(state.source_win) then
    vim.wo[state.source_win].scrollbind = false
    vim.wo[state.source_win].cursorbind = false
  end
  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    vim.api.nvim_win_close(state.preview_win, true)
  end
  if vim.api.nvim_win_is_valid(state.blame_win) then
    vim.api.nvim_win_close(state.blame_win, true)
  end
  if vim.api.nvim_buf_is_valid(state.blame_buf) then
    vim.api.nvim_buf_delete(state.blame_buf, { force = true })
  end
  state = nil
end

---Run blame for a specific commit and file, updating the blame buffer in place
---@param commit string|nil git revision (nil for working tree)
---@param file string file path relative to repo root
---@param target_line number|nil line to place cursor on
local function run_blame(commit, file, target_line)
  local git_dir = vim.fn.FugitiveGitDir()
  if git_dir == "" then
    vim.notify("Not in a git repo", vim.log.levels.ERROR)
    return false
  end

  local work_tree = vim.fn.fnamemodify(git_dir, ":h")
  local cmd = { "git", "-C", work_tree, "blame", "--porcelain" }
  if commit then
    table.insert(cmd, commit)
  end
  table.insert(cmd, "--")
  table.insert(cmd, file)

  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("git blame failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return false
  end

  -- Count lines from source window
  local total_lines
  if commit then
    -- Count lines from blame output (number of content lines)
    total_lines = 0
    for line in result.stdout:gmatch("[^\n]+") do
      if line:match("^\t") then total_lines = total_lines + 1 end
    end
  else
    total_lines = vim.api.nvim_buf_line_count(state.source_buf)
  end

  local entries = parse_porcelain(result.stdout, total_lines)
  local display_lines, max_width = format_entries(entries, total_lines)

  -- Update blame buffer
  vim.bo[state.blame_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.blame_buf, 0, -1, false, display_lines)
  vim.bo[state.blame_buf].modifiable = false

  -- Reapply highlights
  local ns = vim.api.nvim_create_namespace("user_blame")
  vim.api.nvim_buf_clear_namespace(state.blame_buf, ns, 0, -1)
  for i = 1, total_lines do
    local e = entries[i]
    if e then
      vim.api.nvim_buf_set_extmark(state.blame_buf, ns, i - 1, 0, {
        end_col = #display_lines[i],
        hl_group = get_or_create_hl(e.hash),
      })
    end
  end

  state.entries = entries
  vim.api.nvim_win_set_width(state.blame_win, math.min(max_width + 1, 40))

  if target_line then
    pcall(vim.api.nvim_win_set_cursor, state.blame_win, { target_line, 0 })
  end
  return true
end

--- Open commit in source window (like fugitive's <CR>)
local function open_commit()
  if not state then return end
  local line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
  local entry = state.entries[line]
  if not entry or entry.hash:match("^0+$") then return end

  -- Push current state to history
  table.insert(state.history, {
    commit = nil, -- will be determined from source buf
    file = vim.api.nvim_buf_get_name(state.source_buf),
    line = line,
  })

  -- Open the commit's version of the file in source window
  vim.api.nvim_set_current_win(state.source_win)
  vim.cmd("Gedit " .. entry.hash .. ":" .. entry.filename)
  state.source_buf = vim.api.nvim_get_current_buf()

  -- Re-blame at parent
  vim.api.nvim_set_current_win(state.blame_win)
  run_blame(entry.hash, entry.filename, entry.orig_line)
end

--- Go back in blame history (like fugitive's `-`)
local function blame_back()
  if not state then return end
  local line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
  local entry = state.entries[line]
  if not entry or entry.hash:match("^0+$") then return end

  -- Push current state
  table.insert(state.history, {
    buf_name = vim.api.nvim_buf_get_name(state.source_buf),
    line = line,
  })

  -- Open parent commit's file in source window
  local parent = entry.hash .. "~1"
  vim.api.nvim_set_current_win(state.source_win)
  local ok = pcall(vim.cmd, "Gedit " .. parent .. ":" .. entry.filename)
  if not ok then
    table.remove(state.history)
    vim.api.nvim_set_current_win(state.blame_win)
    vim.notify("No parent commit", vim.log.levels.WARN)
    return
  end
  state.source_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_win(state.blame_win)
  run_blame(parent, entry.filename, entry.orig_line)
end

--- Go forward in blame history
local function blame_forward()
  if not state or #state.history == 0 then return end
  local prev = table.remove(state.history)

  vim.api.nvim_set_current_win(state.source_win)
  vim.cmd("Gedit " .. prev.buf_name)
  state.source_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_win(state.blame_win)

  -- Determine commit from the buffer (nil = working tree)
  local ref = vim.fn.FugitiveParse(prev.buf_name)[1] or nil
  local commit = ref and ref:match("^(%x+):") or nil
  local file = ref and ref:match(":(.+)$") or prev.buf_name
  run_blame(commit, file, prev.line)
end

--- Preview commit details in a split above the blame+source
local function preview_commit()
  if not state then return end
  local line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
  local entry = state.entries[line]
  if not entry or entry.hash:match("^0+$") then return end

  -- Close existing preview if any
  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    vim.api.nvim_win_close(state.preview_win, true)
    state.preview_win = nil
    return
  end

  -- Open a horizontal split above spanning full width
  vim.cmd("topleft split")
  local preview_win = vim.api.nvim_get_current_win()
  vim.wo[preview_win].scrollbind = false
  vim.wo[preview_win].cursorbind = false
  vim.cmd("Gedit " .. entry.hash)
  vim.fn.winrestview({ topline = 1, lnum = 1, col = 0 })
  vim.wo[preview_win].winfixheight = true
  vim.api.nvim_win_set_height(preview_win, 15)
  state.preview_win = preview_win

  -- Return focus to blame
  vim.api.nvim_set_current_win(state.blame_win)
end

function M.blame()
  if state then
    close_blame()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  local filepath = vim.api.nvim_buf_get_name(source_buf)

  if filepath == "" then
    vim.notify("No file to blame", vim.log.levels.WARN)
    return
  end

  -- Determine if we're looking at a fugitive object
  local fugitive_path = vim.fn.FugitiveParse(filepath)
  local commit, file
  if fugitive_path and fugitive_path[1] ~= "" then
    commit = fugitive_path[1]:match("^(%x+):")
    file = fugitive_path[1]:match(":(.+)$")
  end
  if not file then
    local git_dir = vim.fn.FugitiveGitDir()
    local work_tree = vim.fn.fnamemodify(git_dir, ":h")
    file = vim.fn.fnamemodify(filepath, ":." ):gsub("^" .. vim.pesc(work_tree .. "/"), "")
    -- Use path relative to work tree
    file = vim.fn.FugitivePath(filepath, "")
  end

  -- Create blame buffer
  local blame_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[blame_buf].buftype = "nofile"
  vim.bo[blame_buf].bufhidden = "wipe"
  vim.bo[blame_buf].filetype = "blame"

  -- Open blame window
  vim.cmd("leftabove vsplit")
  local blame_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(blame_win, blame_buf)

  vim.wo[blame_win].number = false
  vim.wo[blame_win].relativenumber = false
  vim.wo[blame_win].signcolumn = "no"
  vim.wo[blame_win].cursorline = false
  vim.wo[blame_win].foldcolumn = "0"
  vim.wo[blame_win].wrap = false
  vim.wo[blame_win].winfixwidth = true
  vim.wo[blame_win].scrollbind = true
  vim.wo[blame_win].cursorbind = true

  -- Enable scrollbind on source window too
  vim.wo[source_win].scrollbind = true
  vim.wo[source_win].cursorbind = true
  vim.cmd("syncbind")

  -- Init state
  state = {
    source_buf = source_buf,
    source_win = source_win,
    blame_buf = blame_buf,
    blame_win = blame_win,
    entries = {},
    autocmd_ids = {},
    history = {},
  }

  -- Run initial blame
  local cursor_line = vim.api.nvim_win_get_cursor(source_win)[1]
  if not run_blame(commit, file, cursor_line) then
    close_blame()
    return
  end

  -- Keymaps
  local kopts = { buffer = blame_buf, silent = true }
  vim.keymap.set("n", "q", close_blame, kopts)
  vim.keymap.set("n", "<CR>", open_commit, kopts)
  vim.keymap.set("n", "<C-o>", blame_back, kopts)
  vim.keymap.set("n", "<C-i>", blame_forward, kopts)
  vim.keymap.set("n", "P", preview_commit, kopts)

  -- Cursor sync
  local last_preview_hash = nil
  local preview_timer = vim.uv.new_timer()
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = blame_buf,
    callback = function()
      if not state or not state.preview_win or not vim.api.nvim_win_is_valid(state.preview_win) then return end
      preview_timer:stop()
      preview_timer:start(300, 0, vim.schedule_wrap(function()
        if not state or not state.preview_win or not vim.api.nvim_win_is_valid(state.preview_win) then return end
        local line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
        local entry = state.entries[line]
        if not entry or entry.hash:match("^0+$") or entry.hash == last_preview_hash then return end
        last_preview_hash = entry.hash
        local cur_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(state.preview_win)
        vim.cmd("Gedit " .. entry.hash)
        vim.fn.winrestview({ topline = 1, lnum = 1, col = 0 })
        vim.api.nvim_set_current_win(cur_win)
      end))
    end,
  })
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
      if not state then return end
      local win = vim.api.nvim_get_current_win()
      if win ~= state.source_win then return end
      vim.wo[win].scrollbind = true
      vim.wo[win].cursorbind = true
      -- Re-blame if the buffer changed
      local new_buf = vim.api.nvim_win_get_buf(state.source_win)
      if new_buf == state.source_buf then return end
      state.source_buf = new_buf
      local filepath = vim.api.nvim_buf_get_name(new_buf)
      local fugitive_path = vim.fn.FugitiveParse(filepath)
      local commit, file
      if fugitive_path and fugitive_path[1] ~= "" then
        commit = fugitive_path[1]:match("^(%x+):")
        file = fugitive_path[1]:match(":(.+)$")
      end
      if not file then
        file = vim.fn.FugitivePath(filepath, "")
      end
      if file and file ~= "" then
        local cursor_line = vim.api.nvim_win_get_cursor(state.source_win)[1]
        run_blame(commit, file, cursor_line)
      end
    end,
  })
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = blame_buf,
    callback = close_blame,
  })
end

return M
