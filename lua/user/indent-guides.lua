--- Indent guides via 'listchars' rather than a decoration provider, which
--- repaints every visible line on every scroll step.
local M = {}

local util = require("util")

local GUIDE_CHAR = "│"
local GUIDE_COLOR = "#6e738d"
local DETECT_LINES = 400
local MIN_WIDTH, MAX_WIDTH = 2, 8
local BASE_LISTCHARS = "tab:> ,trail:-,nbsp:+"

local skip_filetype = {}
for _, ft in ipairs(util.ignored_filetypes) do
  skip_filetype[ft] = true
end

--- Smallest positive indent in the buffer. 'shiftwidth' would be the obvious
--- source but it is 8 here while almost nothing is indented by 8.
---@return integer|nil step, nil when nothing indented was sampled
local function detect_width(bufnr)
  local best
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, DETECT_LINES, false)) do
    local indent = #(line:match("^ +") or "")
    if indent > 0 and #line > indent and (not best or indent < best) then
      best = indent
    end
  end
  return best
end

local function width(bufnr)
  local cached = vim.b[bufnr].indent_guide_width
  if cached then
    return cached
  end

  local detected = detect_width(bufnr)
  if not detected then
    -- Deliberately not cached: nvim reuses the empty startup buffer for the
    -- first file argument, so caching here pins every such file to the fallback.
    return math.max(MIN_WIDTH, vim.bo[bufnr].tabstop)
  end

  local step = math.min(MAX_WIDTH, math.max(MIN_WIDTH, detected))
  vim.b[bufnr].indent_guide_width = step
  return step
end

local function apply(win)
  win = win == 0 and vim.api.nvim_get_current_win() or win
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local bufnr = vim.api.nvim_win_get_buf(win)

  local float = vim.api.nvim_win_get_config(win).relative ~= ""
  if float or vim.bo[bufnr].buftype ~= "" or skip_filetype[vim.bo[bufnr].filetype] then
    util.set_win_opts(win, { listchars = BASE_LISTCHARS })
    return
  end

  -- Spaces go in literally. The \  escaping is a :set requirement; via the API
  -- the backslashes would be stored as guide characters.
  util.set_win_opts(win, {
    listchars = BASE_LISTCHARS .. ",leadmultispace:" .. GUIDE_CHAR .. string.rep(" ", width(bufnr) - 1),
  })
end

--- Leading listchars use Whitespace, not NonText, and this config re-applies
--- the colorscheme asynchronously after startup, which resets the group.
local function set_highlight()
  vim.api.nvim_set_hl(0, "Whitespace", { fg = GUIDE_COLOR })
end

function M.setup()
  set_highlight()

  local group = vim.api.nvim_create_augroup("user_indent_guides", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_highlight,
    desc = "Keep indent guide colour across colorscheme changes",
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost", "FileType", "WinNew" }, {
    group = group,
    callback = function()
      apply(0)
    end,
    desc = "Set indent guide width for the current window",
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(event)
      vim.b[event.buf].indent_guide_width = nil
      for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
        apply(win)
      end
    end,
    desc = "Re-detect indent guide width after a write",
  })

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    apply(win)
  end
end

return M
