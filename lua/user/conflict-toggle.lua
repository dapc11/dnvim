--- Re-choosable conflict resolution, the way ediff behaves.
---
--- diffview's conflict_choose deletes the conflict region, so once a side is
--- taken the other versions are gone and only undo gets them back. This keeps
--- the three versions in memory and marks the resolved text with an extmark, so
--- pressing another letter swaps the text in place as many times as you like.
local M = {}

local ns = vim.api.nvim_create_namespace("user_conflict_toggle")

--- versions[bufnr][extmark_id] = { ours = {...}, base = {...}, theirs = {...} }
local versions = setmetatable({}, { __mode = "k" })

local MARKER_OURS = "^<<<<<<< "
local MARKER_BASE = "^||||||| "
local MARKER_SEP = "^=======$"
local MARKER_THEIRS = "^>>>>>>> "

---@param bufnr integer
---@param row integer 0-indexed
---@return string
local function line_at(bufnr, row)
  return vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
end

--- Parse the conflict region containing `row`, if any.
---@return table|nil
local function parse_conflict(bufnr, row)
  local total = vim.api.nvim_buf_line_count(bufnr)

  local first
  for i = row, 0, -1 do
    local line = line_at(bufnr, i)
    if line:match(MARKER_OURS) then
      first = i
      break
    end
    -- Walking back out of a different, already closed conflict.
    if i < row and line:match(MARKER_THEIRS) then
      return nil
    end
  end
  if not first then
    return nil
  end

  local base_at, sep_at, last
  for i = first + 1, total - 1 do
    local line = line_at(bufnr, i)
    if not base_at and line:match(MARKER_BASE) then
      base_at = i
    elseif not sep_at and line:match(MARKER_SEP) then
      sep_at = i
    elseif line:match(MARKER_THEIRS) then
      last = i
      break
    end
  end
  if not sep_at or not last then
    return nil
  end

  local get = function(from, to)
    if to <= from then
      return {}
    end
    return vim.api.nvim_buf_get_lines(bufnr, from, to, false)
  end

  return {
    first = first,
    last = last,
    ours = get(first + 1, base_at or sep_at),
    base = base_at and get(base_at + 1, sep_at) or {},
    theirs = get(sep_at + 1, last),
  }
end

--- The extmark covering `row`, if this buffer has a resolved region there.
---@return integer|nil id, integer|nil start_row, integer|nil end_row
local function tracked_at(bufnr, row)
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })) do
    local id, start_row, details = mark[1], mark[2], mark[4]
    local end_row = details and details.end_row or start_row
    -- end_row is exclusive for a multi-line mark, so a zero length region (the
    -- chosen side was empty) still matches on its single row.
    if row >= start_row and row <= math.max(end_row - 1, start_row) then
      return id, start_row, end_row
    end
  end
  return nil
end

---@param which "ours"|"base"|"theirs"|"all"
---@param store table the three versions
---@return string[]
local function text_for(which, store)
  if which == "all" then
    local out = {}
    vim.list_extend(out, store.ours)
    vim.list_extend(out, store.base)
    vim.list_extend(out, store.theirs)
    return out
  end
  return store[which]
end

--- Replace rows [from, to) and re-mark the result so it stays swappable.
local function swap(bufnr, from, to, lines, store, id)
  if id then
    vim.api.nvim_buf_del_extmark(bufnr, ns, id)
  end

  vim.api.nvim_buf_set_lines(bufnr, from, to, false, lines)

  -- A zero length replacement has nothing to anchor to, so mark the row itself
  -- and let the next lookup match on it.
  local end_row = from + math.max(#lines, 1)
  local new_id = vim.api.nvim_buf_set_extmark(bufnr, ns, from, 0, {
    end_row = math.min(end_row, vim.api.nvim_buf_line_count(bufnr)),
    end_col = 0,
    right_gravity = false,
    end_right_gravity = true,
  })

  versions[bufnr] = versions[bufnr] or {}
  versions[bufnr][new_id] = store
  return new_id
end

--- Take a side of the conflict at the cursor, or swap an already taken one.
---@param which "ours"|"base"|"theirs"|"all"
function M.choose(which)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    if not vim.bo[bufnr].modifiable then
      vim.notify("Conflict: this pane is read-only, move to the merged buffer", vim.log.levels.WARN)
      return
    end

    local row = vim.api.nvim_win_get_cursor(0)[1] - 1

    -- Already resolved here: swap to a different version.
    local id, from, to = tracked_at(bufnr, row)
    if id then
      local store = versions[bufnr] and versions[bufnr][id]
      if store then
        swap(bufnr, from, to, text_for(which, store), store, id)
        vim.api.nvim_win_set_cursor(0, { from + 1, 0 })
        return
      end
    end

    -- Otherwise parse a fresh conflict.
    local c = parse_conflict(bufnr, row)
    if not c then
      vim.notify("Conflict: no conflict at the cursor", vim.log.levels.WARN)
      return
    end

    local store = { ours = c.ours, base = c.base, theirs = c.theirs }
    swap(bufnr, c.first, c.last + 1, text_for(which, store), store, nil)
    vim.api.nvim_win_set_cursor(0, { c.first + 1, 0 })
  end
end

--- Put the conflict markers back for the region at the cursor.
function M.restore()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local id, from, to = tracked_at(bufnr, row)
  if not id then
    vim.notify("Conflict: nothing resolved at the cursor", vim.log.levels.WARN)
    return
  end

  local store = versions[bufnr][id]
  local lines = { "<<<<<<< HEAD" }
  vim.list_extend(lines, store.ours)
  if #store.base > 0 then
    lines[#lines + 1] = "||||||| base"
    vim.list_extend(lines, store.base)
  end
  lines[#lines + 1] = "======="
  vim.list_extend(lines, store.theirs)
  lines[#lines + 1] = ">>>>>>> incoming"

  vim.api.nvim_buf_del_extmark(bufnr, ns, id)
  versions[bufnr][id] = nil
  vim.api.nvim_buf_set_lines(bufnr, from, to, false, lines)
  vim.api.nvim_win_set_cursor(0, { from + 1, 0 })
end

--- Buffer-local maps, applied to the merge tool buffers.
---
--- Both schemes run left to right across the top row of diff4_mixed:
---
---   <leader>ca  <leader>c1   left    OURS
---   <leader>cb  <leader>c2   middle  BASE
---   <leader>cc  <leader>c3   right   THEIRS
---
--- Note these digits are pane positions, not git stage numbers, so they differ
--- from 1do/2do/3do where 1 is BASE and 2 is OURS.
---
--- Bare 1/2/3 are not used because they are count prefixes: binding them would
--- break 3j and friends in the merged buffer.
---@param bufnr integer
function M.attach(bufnr)
  local maps = {
    ["<leader>ca"] = { M.choose("ours"), "A: left pane (OURS)" },
    ["<leader>cb"] = { M.choose("base"), "B: middle pane (BASE)" },
    ["<leader>cc"] = { M.choose("theirs"), "C: right pane (THEIRS)" },
    ["<leader>c1"] = { M.choose("ours"), "1: left pane (OURS)" },
    ["<leader>c2"] = { M.choose("base"), "2: middle pane (BASE)" },
    ["<leader>c3"] = { M.choose("theirs"), "3: right pane (THEIRS)" },
    ["<leader>c0"] = { M.choose("all"), "all three versions" },
    ["<leader>cr"] = { M.restore, "restore the conflict markers" },
  }
  for lhs, spec in pairs(maps) do
    vim.keymap.set("n", lhs, spec[1], {
      buffer = bufnr,
      silent = true,
      nowait = true,
      desc = "Conflict: " .. spec[2],
    })
  end
end

return M
