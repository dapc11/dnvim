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
---@field hash_lines table<string, number[]>
---@field autocmd_ids number[]
---@field history table[]
---@field preview_win number|nil
---@field preview_timer uv_timer_t|nil
---@field source_keymaps table[]

local state = nil

-- Git helpers

local function git_work_tree(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":p:h")
  local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then return nil end
  return vim.trim(result.stdout)
end

---@return string|nil commit, string|nil file
local function parse_fugitive_bufname(bufname)
  local ref = bufname:match("^fugitive://.-//(.+)$")
  if not ref then return nil, nil end
  return ref:match("^(%x+):"), ref:match(":(.+)$")
end

local function repo_relative_path(filepath)
  local wt = git_work_tree(filepath)
  if not wt then return nil end
  return vim.fn.fnamemodify(filepath, ":p"):sub(#wt + 2)
end

local function get_commit_message(hash)
  local result = vim.system({ "git", "log", "--format=%B", "-n", "1", hash }, { text = true }):wait()
  return result.code == 0 and result.stdout or ""
end

-- Color helpers

local function hash_to_color(hash)
  local r = tonumber(hash:sub(1, 2), 16)
  local g = tonumber(hash:sub(3, 4), 16)
  local b = tonumber(hash:sub(5, 6), 16)
  r = math.floor(r * 0.5 + 80)
  g = math.floor(g * 0.5 + 80)
  b = math.floor(b * 0.5 + 80)
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

local function setup_hunk_hl()
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg or 0
  local shift = vim.o.background == "dark" and 0x1a1a2a or -0x1a1a2a
  local r = math.min(255, math.max(0, bit.rshift(bit.band(normal_bg, 0xFF0000), 16) + bit.rshift(bit.band(shift, 0xFF0000), 16)))
  local g = math.min(255, math.max(0, bit.rshift(bit.band(normal_bg, 0x00FF00), 8) + bit.rshift(bit.band(shift, 0x00FF00), 8)))
  local b = math.min(255, math.max(0, bit.band(normal_bg, 0x0000FF) + bit.band(shift, 0x0000FF)))
  vim.api.nvim_set_hl(0, "BlameHunk", { bg = string.format("#%02x%02x%02x", r, g, b) })
end

-- Parsing

---@param output string
---@return BlameEntry[], number
local function parse_porcelain(output)
  local entries = {}
  local current = {}
  local hash_data = {}
  local max_line = 0
  for line in output:gmatch("[^\n]+") do
    local hash, orig, final = line:match("^(%x+) (%d+) (%d+)")
    if hash then
      current = { hash = hash, orig_line = tonumber(orig) }
      if hash_data[hash] then
        current.author = hash_data[hash].author
        current.date = hash_data[hash].date
        current.filename = hash_data[hash].filename
      end
      local fl = tonumber(final)
      entries[fl] = current
      if fl > max_line then max_line = fl end
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
  return entries, max_line
end

---@param entries BlameEntry[]
---@param total_lines number
---@return table<string, number[]>
local function build_hash_index(entries, total_lines)
  local index = {}
  for i = 1, total_lines do
    local e = entries[i]
    if e and not e.hash:match("^0+$") then
      if not index[e.hash] then index[e.hash] = {} end
      table.insert(index[e.hash], i)
    end
  end
  return index
end

---@param entries BlameEntry[]
---@param total_lines number
---@return string[], number
local function format_entries(entries, total_lines)
  local lines = {}
  local max_width = 0
  for i = 1, total_lines do
    local e = entries[i]
    local text = e and string.format("%.10s %s %-12s", e.hash, e.date, e.author or "") or ""
    lines[i] = text
    if #text > max_width then max_width = #text end
  end
  return lines, max_width
end

-- Entry accessor (eliminates repeated cursor+lookup+guard pattern)

---@param win number|nil window to read cursor from (defaults to blame_win)
---@return BlameEntry|nil, number line
local function get_current_entry(win)
  if not state then return nil, 0 end
  win = win or state.blame_win
  if not vim.api.nvim_win_is_valid(win) then return nil, 0 end
  local line = vim.api.nvim_win_get_cursor(win)[1]
  local entry = state.entries[line]
  if not entry or entry.hash:match("^0+$") then return nil, line end
  return entry, line
end

-- State management

local function close_blame()
  if not state then return end
  local s = state
  state = nil
  for _, id in ipairs(s.autocmd_ids) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  for _, km in ipairs(s.source_keymaps) do
    pcall(vim.keymap.del, km.mode, km.lhs, { buffer = km.buffer })
  end
  if vim.api.nvim_win_is_valid(s.source_win) then
    vim.wo[s.source_win].scrollbind = false
    vim.wo[s.source_win].cursorbind = false
  end
  if vim.api.nvim_buf_is_valid(s.source_buf) then
    vim.api.nvim_buf_clear_namespace(s.source_buf, vim.api.nvim_create_namespace("blame_hunk_hl"), 0, -1)
  end
  if s.preview_win and vim.api.nvim_win_is_valid(s.preview_win) then
    vim.api.nvim_win_close(s.preview_win, true)
  end
  if s.preview_timer then
    s.preview_timer:stop()
    if not s.preview_timer:is_closing() then s.preview_timer:close() end
  end
  if vim.api.nvim_win_is_valid(s.source_win) then
    vim.api.nvim_set_current_win(s.source_win)
  end
  if vim.api.nvim_win_is_valid(s.blame_win) then
    vim.api.nvim_win_close(s.blame_win, true)
  end
end

---@param commit string|nil
---@param file string
---@param target_line number|nil
---@param line_range table|nil {start, finish}
---@param callback function|nil
local function run_blame(commit, file, target_line, line_range, callback)
  if not state then return end

  local work_tree = git_work_tree(vim.api.nvim_buf_get_name(state.source_buf))
  if not work_tree then
    vim.notify("Not in a git repo", vim.log.levels.ERROR)
    if callback then callback(false) end
    return
  end

  local cmd = { "git", "-C", work_tree, "blame", "--porcelain" }
  if line_range then
    table.insert(cmd, "-L")
    table.insert(cmd, line_range[1] .. "," .. line_range[2])
  end
  if commit then table.insert(cmd, commit) end
  table.insert(cmd, "--")
  table.insert(cmd, file)

  local s = state
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if state ~= s then return end
      if not vim.api.nvim_buf_is_valid(s.blame_buf) then return end
      if result.code ~= 0 then
        vim.notify("git blame failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
        if callback then callback(false) end
        return
      end

      local entries, total_lines = parse_porcelain(result.stdout)
      if not commit and not line_range then
        total_lines = vim.api.nvim_buf_line_count(state.source_buf)
      end

      local display_lines, max_width = format_entries(entries, total_lines)

      vim.bo[state.blame_buf].modifiable = true
      vim.api.nvim_buf_set_lines(state.blame_buf, 0, -1, false, display_lines)
      vim.bo[state.blame_buf].modifiable = false

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
      state.hash_lines = build_hash_index(entries, total_lines)
      if vim.api.nvim_win_is_valid(state.blame_win) then
        vim.api.nvim_win_set_width(state.blame_win, math.min(max_width + 1, 44))
      end

      if target_line then
        pcall(vim.api.nvim_win_set_cursor, state.blame_win, { target_line, 0 })
      end
      if callback then callback(true) end
    end)
  end)
end

-- Actions

local function open_commit()
  local entry, line = get_current_entry()
  if not entry then return end

  local prev_source_buf = state.source_buf
  table.insert(state.history, {
    commit = nil,
    file = vim.api.nvim_buf_get_name(state.source_buf),
    line = line,
  })

  vim.api.nvim_set_current_win(state.source_win)
  vim.cmd("Gedit " .. entry.hash .. ":" .. entry.filename)
  state.source_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_win(state.blame_win)

  run_blame(entry.hash, entry.filename, entry.orig_line, nil, function(ok)
    if not ok and state then
      table.remove(state.history)
      vim.api.nvim_set_current_win(state.source_win)
      if vim.api.nvim_buf_is_valid(prev_source_buf) then
        vim.api.nvim_win_set_buf(state.source_win, prev_source_buf)
      end
      state.source_buf = prev_source_buf
      vim.api.nvim_set_current_win(state.blame_win)
    end
  end)
end

local function blame_back()
  local entry, line = get_current_entry()
  if not entry then return end

  local cur_name = vim.api.nvim_buf_get_name(state.source_buf)
  local cur_commit, cur_file = parse_fugitive_bufname(cur_name)
  if not cur_file then cur_file = repo_relative_path(cur_name) end

  table.insert(state.history, { commit = cur_commit, file = cur_file, line = line })

  local result = vim.system({ "git", "rev-parse", entry.hash .. "^@" }, { text = true }):wait()
  local parents = {}
  if result.code == 0 then
    for p in result.stdout:gmatch("%x+") do table.insert(parents, p) end
  end

  local function navigate_to_parent(parent)
    vim.api.nvim_set_current_win(state.source_win)
    local ok = pcall(vim.cmd, "Gedit " .. parent .. ":" .. entry.filename)
    if not ok then
      table.remove(state.history)
      vim.api.nvim_set_current_win(state.blame_win)
      vim.notify("File not found in parent", vim.log.levels.WARN)
      return
    end
    state.source_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_win(state.blame_win)
    run_blame(parent, entry.filename, entry.orig_line)
  end

  if #parents > 1 then
    local choices = {}
    for i, p in ipairs(parents) do choices[i] = string.format("%d: %s", i, p:sub(1, 10)) end
    vim.ui.select(choices, { prompt = "Select parent:" }, function(_, idx)
      if not idx or not state then
        if state then table.remove(state.history) end
        return
      end
      navigate_to_parent(parents[idx])
    end)
  else
    navigate_to_parent(entry.hash .. "~1")
  end
end

local function blame_forward()
  if not state or #state.history == 0 then return end
  local prev = table.remove(state.history)

  vim.api.nvim_set_current_win(state.source_win)
  if prev.commit then
    vim.cmd("Gedit " .. prev.commit .. ":" .. prev.file)
  else
    vim.cmd("Gedit " .. prev.file)
  end
  state.source_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_win(state.blame_win)
  run_blame(prev.commit, prev.file, prev.line)
end

local function preview_commit()
  local entry = get_current_entry()
  if not entry then return end

  if state.preview_win then
    if vim.api.nvim_win_is_valid(state.preview_win) then
      vim.api.nvim_win_close(state.preview_win, true)
    end
    state.preview_win = nil
    return
  end

  vim.cmd("topleft split")
  local preview_win = vim.api.nvim_get_current_win()
  vim.wo[preview_win].scrollbind = false
  vim.wo[preview_win].cursorbind = false
  vim.cmd("Gedit " .. entry.hash)
  vim.fn.winrestview({ topline = 1, lnum = 1, col = 0 })
  vim.wo[preview_win].winfixheight = true
  vim.api.nvim_win_set_height(preview_win, 15)
  state.preview_win = preview_win

  vim.keymap.set("n", "q", function()
    if state and state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
      vim.api.nvim_win_close(state.preview_win, true)
      state.preview_win = nil
    end
    if state and vim.api.nvim_win_is_valid(state.blame_win) then
      vim.api.nvim_set_current_win(state.blame_win)
    end
  end, { buffer = vim.api.nvim_win_get_buf(preview_win), silent = true })

  vim.api.nvim_set_current_win(state.blame_win)
end

local function jump_commit_boundary(forward)
  if not state then return end
  local cur_line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
  local current_hash = state.entries[cur_line] and state.entries[cur_line].hash
  if not current_hash then return end
  local total = vim.api.nvim_buf_line_count(state.blame_buf)
  if forward then
    for i = cur_line + 1, total do
      if state.entries[i] and state.entries[i].hash ~= current_hash then
        vim.api.nvim_win_set_cursor(state.blame_win, { i, 0 })
        return
      end
    end
  else
    for i = cur_line - 1, 1, -1 do
      if state.entries[i] and state.entries[i].hash ~= current_hash then
        local target_hash = state.entries[i].hash
        local target = i
        for j = i - 1, 1, -1 do
          if state.entries[j] and state.entries[j].hash == target_hash then target = j else break end
        end
        vim.api.nvim_win_set_cursor(state.blame_win, { target, 0 })
        return
      end
    end
  end
end

local function jump_hunk_occurrence(forward)
  if not state then return end
  local cur_line = vim.api.nvim_win_get_cursor(state.source_win)[1]
  local entry = state.entries[cur_line]
  local hash = entry and entry.hash
  if not hash or hash:match("^0+$") then return end
  local line_list = state.hash_lines[hash]
  if not line_list then return end

  if forward then
    local i = cur_line + 1
    while state.entries[i] and state.entries[i].hash == hash do i = i + 1 end
    for _, ln in ipairs(line_list) do
      if ln >= i then
        vim.api.nvim_win_set_cursor(state.source_win, { ln, 0 })
        return
      end
    end
  else
    local i = cur_line - 1
    while i >= 1 and state.entries[i] and state.entries[i].hash == hash do i = i - 1 end
    for j = #line_list, 1, -1 do
      if line_list[j] <= i then
        local target = line_list[j]
        while target > 1 and state.entries[target - 1] and state.entries[target - 1].hash == hash do target = target - 1 end
        vim.api.nvim_win_set_cursor(state.source_win, { target, 0 })
        return
      end
    end
  end
end

-- External openers

local function open_gerrit()
  local entry = get_current_entry()
  if not entry then return end
  local gerrit_url = os.getenv("GERRIT_URL")
  if not gerrit_url then vim.notify("GERRIT_URL not set", vim.log.levels.WARN); return end

  local msg = get_commit_message(entry.hash)
  local change_id = msg:match("Change%-Id: (I[a-f0-9]+)")
  if not change_id then vim.notify("No Change-Id in commit", vim.log.levels.WARN); return end

  local remote_url = vim.trim(vim.fn.system("git config --get remote.origin.url"))
  local project_path = remote_url:match("/([^/]+/[^/]+/[^/]+)%.git")
    or remote_url:match("/a/(.+)%.git")
    or remote_url:match("/a/(.+)$")
  if not project_path then vim.notify("Cannot determine project path", vim.log.levels.WARN); return end

  local api_url = gerrit_url .. "/a/changes/?q=change:" .. change_id .. "+project:" .. project_path
  vim.system({ "curl", "-s", "--netrc", api_url }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then vim.notify("Gerrit API request failed", vim.log.levels.WARN); return end
      local change_num = result.stdout:gsub("^[^%[]*", ""):match('"_number":(%d+)')
      if not change_num then vim.notify("Gerrit change not found", vim.log.levels.WARN); return end
      vim.fn.jobstart({ "xdg-open", gerrit_url .. "/c/" .. project_path .. "/+/" .. change_num }, { detach = true })
    end)
  end)
end

local function open_jira(field)
  local entry = get_current_entry()
  if not entry then return end
  local msg = get_commit_message(entry.hash)
  local jira_id = msg:match(field .. ":%s*([A-Z]+-[0-9]+)")
  if not jira_id then vim.notify("No " .. field .. " ID in commit", vim.log.levels.WARN); return end
  local jira_url = os.getenv("JIRA_URL") or ""
  if jira_url == "" then vim.notify("JIRA_URL not set", vim.log.levels.WARN); return end
  vim.fn.jobstart({ "xdg-open", jira_url .. jira_id }, { detach = true })
end

local function yank_hash()
  local entry = get_current_entry()
  if not entry then return end
  vim.fn.setreg("+", entry.hash)
  vim.notify("Yanked " .. entry.hash)
end

local function yank_hunk()
  if not state then return end
  local cur = vim.api.nvim_win_get_cursor(state.source_win)[1]
  local entry = state.entries[cur]
  if not entry or entry.hash:match("^0+$") then return end
  local hash = entry.hash
  local start, finish = cur, cur
  while start > 1 and state.entries[start - 1] and state.entries[start - 1].hash == hash do start = start - 1 end
  local total = vim.api.nvim_buf_line_count(state.source_buf)
  while finish < total and state.entries[finish + 1] and state.entries[finish + 1].hash == hash do finish = finish + 1 end
  local lines = vim.api.nvim_buf_get_lines(state.source_buf, start - 1, finish, false)
  vim.fn.setreg("+", table.concat(lines, "\n") .. "\n")
  vim.notify(string.format("Yanked %d lines", #lines))
end

-- Shared setup

---@param opts { source_buf: number, source_win: number, scrollbind: boolean }
---@return number blame_buf, number blame_win
local function create_blame_window(opts)
  local blame_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[blame_buf].buftype = "nofile"
  vim.bo[blame_buf].bufhidden = "wipe"
  vim.bo[blame_buf].filetype = "blame"

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

  if opts.scrollbind then
    vim.wo[blame_win].scrollbind = true
    vim.wo[blame_win].cursorbind = true
    vim.wo[opts.source_win].scrollbind = true
    vim.wo[opts.source_win].cursorbind = true
    vim.cmd("syncbind")
  end

  state = {
    source_buf = opts.source_buf,
    source_win = opts.source_win,
    blame_buf = blame_buf,
    blame_win = blame_win,
    entries = {},
    hash_lines = {},
    autocmd_ids = {},
    history = {},
    source_keymaps = {},
  }

  -- Cleanup autocmds
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = blame_buf,
    callback = close_blame,
  })
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(blame_win),
    once = true,
    callback = function() vim.schedule(close_blame) end,
  })

  return blame_buf, blame_win
end

---@param blame_buf number
local function setup_blame_keymaps(blame_buf)
  local kopts = { buffer = blame_buf, silent = true }
  vim.keymap.set("n", "q", close_blame, kopts)
  vim.keymap.set("n", "P", preview_commit, kopts)
  vim.keymap.set("n", "p", preview_commit, kopts)
  vim.keymap.set("n", "gj", function() open_jira("Jira") end, kopts)
  vim.keymap.set("n", "gr", function() open_jira("Requirement") end, kopts)
  vim.keymap.set("n", "go", open_gerrit, kopts)
  vim.keymap.set("n", "yc", yank_hash, { buffer = blame_buf, silent = true, nowait = true })
end

---Resolve commit and file from a buffer
---@param buf number
---@return string|nil commit, string|nil file
local function resolve_blame_target(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" or vim.bo[buf].buftype ~= "" then
    vim.notify("Cannot blame this buffer", vim.log.levels.WARN)
    return nil, nil
  end
  local commit, file = parse_fugitive_bufname(filepath)
  if not file then file = repo_relative_path(filepath) end
  if not file or file == "" then
    vim.notify("Cannot determine file path", vim.log.levels.ERROR)
    return nil, nil
  end
  return commit, file
end

-- Public API

function M.blame()
  if state then close_blame(); return end

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  local commit, file = resolve_blame_target(source_buf)
  if not file then return end

  setup_hunk_hl()
  local blame_buf, blame_win = create_blame_window({
    source_buf = source_buf,
    source_win = source_win,
    scrollbind = true,
  })

  local cursor_line = vim.api.nvim_win_get_cursor(source_win)[1]
  run_blame(commit, file, cursor_line, nil, function(ok)
    if not ok then close_blame(); return end
  end)

  -- Keymaps
  setup_blame_keymaps(blame_buf)
  local kopts = { buffer = blame_buf, silent = true }
  vim.keymap.set("n", "<CR>", open_commit, kopts)
  vim.keymap.set("n", "<C-o>", blame_back, kopts)
  vim.keymap.set("n", "<C-i>", blame_forward, kopts)
  vim.keymap.set("n", "<h", function() jump_commit_boundary(true) end, kopts)
  vim.keymap.set("n", ">h", function() jump_commit_boundary(false) end, kopts)

  -- Source buffer keymaps (tracked for cleanup)
  local src_kopts = { buffer = source_buf, silent = true }
  local function add_src_keymap(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, src_kopts)
    table.insert(state.source_keymaps, { mode = mode, lhs = lhs, buffer = source_buf })
  end
  add_src_keymap("n", "<h", function() jump_hunk_occurrence(true) end)
  add_src_keymap("n", ">h", function() jump_hunk_occurrence(false) end)
  add_src_keymap("n", "P", preview_commit)
  add_src_keymap("n", "yih", yank_hunk)

  -- Hunk highlighting
  local hl_ns = vim.api.nvim_create_namespace("blame_hunk_hl")
  local last_hl_hash = nil

  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = blame_buf,
    callback = function()
      if not state or not vim.api.nvim_buf_is_valid(state.source_buf) then return end
      if not vim.api.nvim_win_is_valid(state.blame_win) then return end
      local line = vim.api.nvim_win_get_cursor(state.blame_win)[1]
      local entry = state.entries[line]
      if not entry or entry.hash == last_hl_hash then return end
      last_hl_hash = entry.hash
      vim.api.nvim_buf_clear_namespace(state.source_buf, hl_ns, 0, -1)
      if entry.hash:match("^0+$") then return end
      local line_list = state.hash_lines[entry.hash]
      if not line_list then return end
      local buf_lines = vim.api.nvim_buf_line_count(state.source_buf)
      for _, ln in ipairs(line_list) do
        if ln <= buf_lines then
          vim.api.nvim_buf_set_extmark(state.source_buf, hl_ns, ln - 1, 0, {
            end_row = math.min(ln, buf_lines),
            hl_group = "BlameHunk",
            hl_eol = true,
          })
        end
      end
    end,
  })

  -- Auto-update preview on cursor move
  local last_preview_hash = nil
  local preview_timer = vim.uv.new_timer()
  state.preview_timer = preview_timer

  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = blame_buf,
    callback = function()
      if not state or not state.preview_win then return end
      if not vim.api.nvim_win_is_valid(state.preview_win) then
        state.preview_win = nil
        return
      end
      preview_timer:stop()
      preview_timer:start(300, 0, vim.schedule_wrap(function()
        if not state or not state.preview_win or not vim.api.nvim_win_is_valid(state.preview_win) then
          if state then state.preview_win = nil end
          return
        end
        if not vim.api.nvim_win_is_valid(state.blame_win) then return end
        local entry = get_current_entry()
        if not entry or entry.hash == last_preview_hash then return end
        last_preview_hash = entry.hash
        local cur_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(state.preview_win)
        vim.cmd("Gedit " .. entry.hash)
        vim.fn.winrestview({ topline = 1, lnum = 1, col = 0 })
        vim.api.nvim_set_current_win(cur_win)
      end))
    end,
  })

  -- Re-blame on source buffer change
  state.autocmd_ids[#state.autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
      if not state then return end
      local win = vim.api.nvim_get_current_win()
      if win ~= state.source_win then return end
      vim.wo[win].scrollbind = true
      vim.wo[win].cursorbind = true
      local new_buf = vim.api.nvim_win_get_buf(state.source_win)
      if new_buf == state.source_buf then return end
      state.source_buf = new_buf
      state.history = {}
      local fp = vim.api.nvim_buf_get_name(new_buf)
      local c, f = parse_fugitive_bufname(fp)
      if not f then f = repo_relative_path(fp) end
      if f and f ~= "" then
        run_blame(c, f, vim.api.nvim_win_get_cursor(state.source_win)[1])
      end
    end,
  })
end

---@param line1 number
---@param line2 number
function M.blame_range(line1, line2)
  if state then close_blame() end

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  local commit, file = resolve_blame_target(source_buf)
  if not file then return end

  local blame_buf = create_blame_window({
    source_buf = source_buf,
    source_win = source_win,
    scrollbind = false,
  })

  run_blame(commit, file, 1, { line1, line2 }, function(ok)
    if not ok then close_blame(); return end
  end)

  setup_blame_keymaps(blame_buf)
end

return M
