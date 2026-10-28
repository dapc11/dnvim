-- gf for markdown: follows the link under the cursor.
--
--   [text](https://...)  [text](#heading)  [text](file.md#heading)
--   [text][label]  [label]  <https://...>  bare https://...
--
-- URLs open in the browser, #anchors jump to the heading with that GitHub slug and paths open relative
-- to the buffer. Anything else falls back to the builtin gf.

local M = {}

local function headings()
  local result, seen, fenced = {}, {}, false
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match("^%s*```") or line:match("^%s*~~~") then
      fenced = not fenced
    end
    local title = not fenced and line:match("^#+%s+(.-)%s*#*%s*$")
    if title then
      local slug = title:gsub("%[(.-)%]%b()", "%1"):lower():gsub("[^%w%s_%-\128-\255]", ""):gsub("%s", "-")
      -- GitHub suffixes repeated headings with -1, -2, ...
      result[seen[slug] and slug .. "-" .. seen[slug] or slug] = lnum
      seen[slug] = (seen[slug] or 0) + 1
    end
  end
  return result
end

local function normalize_label(label)
  return (label:gsub("%s+", " "):lower())
end

local function definitions()
  local result = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local label, target = line:match("^%s*%[([^%]]+)%]:%s*<?([^%s>]+)")
    if label then
      result[normalize_label(label)] = target
    end
  end
  return result
end

---Link target under the cursor. Looks at the neighbouring lines too, since reference labels wrap.
---@return string|nil
local function target_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local first = math.max(row - 1, 1)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, row + 1, false)
  local text = table.concat(lines, "\n")
  local cursor = #table.concat(vim.list_slice(lines, 1, row - first), "\n") + (row > first and 1 or 0) + col + 1

  ---Captures of the first match of pattern that covers the cursor.
  local function at_cursor(pattern)
    local init = 1
    while true do
      local match = { text:find(pattern, init) }
      if not match[1] or match[1] > cursor then
        return nil
      end
      if cursor <= match[2] then
        return unpack(match, 3)
      end
      init = match[1] + 1
    end
  end

  local destination = at_cursor("%b[](%b())")
  if destination then
    return destination:sub(2, -2):match("^%s*<?([^%s>]*)")
  end

  local label_text, label = at_cursor("%[([^%]]*)%]%[([^%]]*)%]")
  if label == "" then
    label = label_text
  end
  label = label or at_cursor("%[([^%]]+)%]")
  local reference = label and definitions()[normalize_label(label)]
  if reference then
    return reference
  end

  local url = at_cursor("(https?://[^%s<>%)%]]+)")
  return url and (url:gsub("[.,;:]+$", ""))
end

function M.follow()
  local target = target_under_cursor()
  if not target or target == "" then
    local ok, err = pcall(vim.cmd.normal, { "gf", bang = true })
    if not ok then
      vim.notify((err:gsub("^.-:E", "E")), vim.log.levels.ERROR)
    end
    return
  end

  if target:match("^%a[%w+.-]*:") then
    local _, err = vim.ui.open(target)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return
  end

  target = target:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  local path, anchor = target:match("^([^#]*)#?(.*)$")
  if path ~= "" then
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    local file = vim.fs.normalize(path:match("^[/~]") and path or dir .. "/" .. path)
    if not vim.uv.fs_stat(file) then
      vim.notify("File not found: " .. file, vim.log.levels.ERROR)
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(file))
  end
  if anchor ~= "" then
    local lnum = headings()[anchor:lower()]
    if not lnum then
      vim.notify("Heading not found: #" .. anchor, vim.log.levels.ERROR)
      return
    end
    vim.cmd.normal({ lnum .. "G", bang = true })
  end
end

return M
