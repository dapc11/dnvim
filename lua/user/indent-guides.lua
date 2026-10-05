--- Indent guides drawn by 'listchars' instead of a decoration provider.
---
--- indentmini.nvim, and every other indent-guide plugin built on
--- nvim_set_decoration_provider, places an extmark on each visible line on
--- every redraw. Virtual text changes the rendered content of those lines, so
--- nvim has to repaint the whole window on each scroll step rather than
--- letting the terminal shift its own scroll region. Measured on a 369 line
--- Dockerfile in a 120x40 pty, scrolling with CTRL-E:
---
---   indentmini on    1.36 ms/line   52662 bytes written to the terminal
---   indentmini off   0.08 ms/line    2323 bytes
---
--- 'listchars' guides are part of the line content, so the cheap scroll path
--- survives. The trade-off is that guides cannot be drawn on empty lines and
--- the spacing is one fixed width per buffer rather than per indent level.
local M = {}

local util = require("util")

local GUIDE_CHAR = "│"
local GUIDE_COLOR = "#6e738d"

-- Lines sampled when guessing the indent step. Enough to cover the top of any
-- hand-written file without turning buffer entry into a full scan.
local DETECT_LINES = 400
local MIN_WIDTH, MAX_WIDTH = 2, 8

-- Everything except leadmultispace, which is appended per buffer. Keeping the
-- nvim defaults means enabling guides does not silently drop the tab, trailing
-- space and non-breaking space markers.
local BASE_LISTCHARS = "tab:> ,trail:-,nbsp:+"

local skip_filetype = {}
for _, ft in ipairs(util.ignored_filetypes) do
  skip_filetype[ft] = true
end

--- Smallest positive leading-space count in the buffer, which for
--- consistently formatted code is the indent step. Reading 'shiftwidth' would
--- be the obvious source, but it is 8 here by default while almost nothing is
--- actually indented by 8, so the file itself is the more reliable witness.
---@param bufnr integer
---@return integer|nil step, nil when the sample held no indented line
local function detect_width(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, DETECT_LINES, false)
  local best
  for _, line in ipairs(lines) do
    local indent = #(line:match("^ +") or "")
    -- A blank or whitespace-only line carries no nesting information.
    if indent > 0 and #line > indent and (not best or indent < best) then
      best = indent
    end
  end
  return best
end

---@param bufnr integer
---@return integer
local function width(bufnr)
  local cached = vim.b[bufnr].indent_guide_width
  if cached then
    return cached
  end

  local detected = detect_width(bufnr)
  if not detected then
    -- Either the file has no indentation, in which case no guide renders and
    -- the width is irrelevant, or the buffer has not been read yet. Nvim
    -- reuses the empty startup buffer for the first file argument, so caching
    -- here would pin the width of every such file to this fallback.
    return math.max(MIN_WIDTH, vim.bo[bufnr].tabstop)
  end

  local step = math.min(MAX_WIDTH, math.max(MIN_WIDTH, detected))
  vim.b[bufnr].indent_guide_width = step
  return step
end

---@param win integer window handle, 0 for the current window
local function apply(win)
  win = win == 0 and vim.api.nvim_get_current_win() or win
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local bufnr = vim.api.nvim_win_get_buf(win)

  -- Floating windows, scratch buffers and the plugin UIs in ignored_filetypes
  -- are not code, and guides there are noise.
  local float = vim.api.nvim_win_get_config(win).relative ~= ""
  if float or vim.bo[bufnr].buftype ~= "" or skip_filetype[vim.bo[bufnr].filetype] then
    util.set_win_opts(win, { listchars = BASE_LISTCHARS })
    return
  end

  -- Spaces are written literally. Backslash escaping is a :set command-line
  -- requirement, not an API one; nvim_set_option_value would store the
  -- backslashes as guide characters. The default tab:> entry carries a literal
  -- space for the same reason.
  util.set_win_opts(win, {
    listchars = BASE_LISTCHARS .. ",leadmultispace:" .. GUIDE_CHAR .. string.rep(" ", width(bufnr) - 1),
  })
end

--- 'listchars' leading characters are drawn with Whitespace, not NonText.
--- Applying a colorscheme resets the group, and this config re-applies the
--- colorscheme asynchronously once the terminal background is known, so the
--- colour has to be restored on every ColorScheme.
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

  -- Reformatting can change the indent step, and the detected width is cached
  -- per buffer, so drop the cache when the file is written.
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
