-- Todo keyword highlighting and navigation.
--
-- Highlighting runs as a decoration provider: nvim invokes `on_line` only for
-- lines it is actually redrawing, so the cost is bounded by the viewport and is
-- independent of buffer size. Extmarks are ephemeral, so nothing is stored,
-- nothing needs invalidating, and there are no autocmds on the hot path.
--
-- Per line the work is a handful of plain (non-regex) string.find calls, which
-- are memchr-backed and measurably faster than a single Lua-pattern pass.

local map = require("util").map

local M = {}

local keywords = {
  TODO = "TodoKeyTodo",
  FIXME = "TodoKeyFix",
  XXX = "TodoKeyFix",
  HACK = "TodoKeyHack",
  WARN = "TodoKeyWarn",
  PERF = "TodoKeyPerf",
  NOTE = "TodoKeyNote",
}

-- Plain-text search needs a list, not a hash, to keep the inner loop tight.
local kw_list = {}
for word, hl in pairs(keywords) do
  kw_list[#kw_list + 1] = { word = word, hl = hl }
end

local words = vim.tbl_keys(keywords)

-- Vim regex for the jump maps, and an rg regex for the picker. Both are
-- derived from the same keyword set so the three features can never disagree.
M.pattern = [[\v<(]] .. table.concat(words, "|") .. [[)>]]
M.rg_pattern = [[\b(]] .. table.concat(words, "|") .. [[)\b]]

-- Never scan more than this many bytes of one line. Guards against minified
-- or generated files with pathologically long lines.
local MAX_LINE = 2000

local ns = vim.api.nvim_create_namespace("user_todo")

local function is_word_byte(b)
  if not b then
    return false
  end
  return (b >= 48 and b <= 57) -- 0-9
    or (b >= 65 and b <= 90) -- A-Z
    or (b >= 97 and b <= 122) -- a-z
    or b == 95 -- _
end

--- Find todo keywords in a line, calling cb(start_col, end_col, hl_group).
--- Columns are 0-indexed byte offsets, end exclusive.
function M.scan(line, cb)
  local len = #line
  if len == 0 then
    return
  end

  for i = 1, #kw_list do
    local kw = kw_list[i]
    local from = 1
    while true do
      local s, e = line:find(kw.word, from, true) -- plain=true: no regex
      -- Bail out past the cap rather than slicing the line, which would
      -- allocate a copy on every redraw of a long line.
      if not s or s > MAX_LINE then
        break
      end
      -- Reject substring hits such as TODOS or NOTEBOOK.
      local before = s > 1 and line:byte(s - 1) or nil
      local after = e < len and line:byte(e + 1) or nil
      if not is_word_byte(before) and not is_word_byte(after) then
        cb(s - 1, e, kw.hl)
      end
      from = e + 1
    end
  end
end

-- Each todo group takes its colour from a Diagnostic group so it tracks the
-- colourscheme, with a fallback for schemes that leave those undefined.
local groups = {
  TodoKeyTodo = { source = "DiagnosticInfo", fallback = 0x4fa6ed },
  TodoKeyFix = { source = "DiagnosticError", fallback = 0xdb4b4b },
  TodoKeyHack = { source = "DiagnosticWarn", fallback = 0xe0af68 },
  TodoKeyWarn = { source = "DiagnosticWarn", fallback = 0xe0af68 },
  TodoKeyPerf = { source = "DiagnosticHint", fallback = 0x1abc9c },
  TodoKeyNote = { source = "DiagnosticHint", fallback = 0x10b981 },
}

--- WCAG relative luminance of a 24-bit RGB value.
local function luminance(rgb)
  local function channel(c)
    c = c / 255
    if c <= 0.03928 then
      return c / 12.92
    end
    return ((c + 0.055) / 1.055) ^ 2.4
  end
  local r = math.floor(rgb / 65536) % 256
  local g = math.floor(rgb / 256) % 256
  local b = rgb % 256
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

local function contrast(a, b)
  local la, lb = luminance(a), luminance(b)
  if la < lb then
    la, lb = lb, la
  end
  return (la + 0.05) / (lb + 0.05)
end

-- WCAG AA for normal-size text.
local MIN_CONTRAST = 4.5

--- Text colour to sit on `badge`: the editor background if it is legible,
--- otherwise white, otherwise black.
local function pick_fg(badge, normal_bg)
  if normal_bg and contrast(badge, normal_bg) >= MIN_CONTRAST then
    return normal_bg
  end
  if contrast(badge, 0xffffff) >= MIN_CONTRAST then
    return 0xffffff
  end
  return 0x000000
end

local function set_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local normal_bg = normal and normal.bg -- nil on transparent backgrounds

  for name, spec in pairs(groups) do
    local src = vim.api.nvim_get_hl(0, { name = spec.source, link = false })
    local badge = (src and src.fg) or spec.fallback
    -- Inverted: the keyword colour becomes the background.
    vim.api.nvim_set_hl(0, name, {
      bg = badge,
      fg = pick_fg(badge, normal_bg),
      bold = true,
    })
  end
end

function M.jump(flags)
  if vim.fn.search(M.pattern, flags) == 0 then
    vim.notify("No todo comments in buffer", vim.log.levels.INFO)
  else
    vim.cmd("norm! zz")
  end
end

--- Project-wide todo search. Requiring fzf-lua here rather than at module load
--- keeps the plugin lazy.
function M.pick()
  require("fzf-lua").grep({ search = M.rg_pattern, no_esc = true })
end

local function setup_highlighting()
  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("user_todo", { clear = true }),
    callback = set_highlights,
    desc = "Re-link todo keyword highlights",
  })

  local get_lines = vim.api.nvim_buf_get_lines
  local set_extmark = vim.api.nvim_buf_set_extmark

  -- One closure for the whole session rather than one per redrawn line: the
  -- current buffer and row are passed as upvalues so `on_line` allocates
  -- nothing beyond the line string itself.
  local cur_buf, cur_row = 0, 0
  local function emit(start_col, end_col, hl)
    set_extmark(cur_buf, ns, cur_row, start_col, {
      end_col = end_col,
      hl_group = hl,
      ephemeral = true,
      priority = 200, -- above treesitter's default of 100
    })
  end

  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, bufnr)
      -- Skip terminals and other non-file buffers.
      return vim.bo[bufnr].buftype == ""
    end,
    on_line = function(_, _, bufnr, row)
      local line = get_lines(bufnr, row, row + 1, false)[1]
      if line then
        cur_buf, cur_row = bufnr, row
        M.scan(line, emit)
      end
    end,
  })
end

local function setup_keymaps()
  map("n", "]t", function()
    M.jump("w")
  end, { desc = "Next todo comment" })

  map("n", "[t", function()
    M.jump("bw")
  end, { desc = "Previous todo comment" })

  map("n", "<leader>ft", M.pick, { desc = "Find Todo Comments" })
end

setup_highlighting()
setup_keymaps()

return M
