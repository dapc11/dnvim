--[[
CSV Alignment Plugin for Neovim

Automatically formats CSV files with aligned columns for better readability.
Creates a new buffer with the formatted view while keeping the original file intact.

Key mappings (CSV files only):
- Ctrl+Left/Right: Navigate between columns
- Shift+Left/Right: Jump to beginning/end of line
- Ctrl+S: Sort by current column (preserves header)

Features:
- Handles quoted fields with commas and newlines
- Performance optimized for large files
- Syntax highlighting disabled for better performance
--]]

local M = {}

local function parse_csv(text)
  local rows = {}
  local current_row = {}
  local current_field = ""
  local in_quotes = false
  local i = 1

  while i <= #text do
    local char = text:sub(i, i)

    if char == '"' then
      if in_quotes and i < #text and text:sub(i + 1, i + 1) == '"' then
        current_field = current_field .. '"'
        i = i + 1
      else
        in_quotes = not in_quotes
      end
    elseif char == "," and not in_quotes then
      table.insert(current_row, current_field)
      current_field = ""
    elseif char == "\n" and not in_quotes then
      table.insert(current_row, current_field)
      table.insert(rows, current_row)
      current_row = {}
      current_field = ""
    else
      current_field = current_field .. char
    end
    i = i + 1
  end

  if current_field ~= "" or #current_row > 0 then
    table.insert(current_row, current_field)
    table.insert(rows, current_row)
  end

  return rows
end

local function get_column_index()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local count = 0
  for i = 1, col do
    if line:sub(i, i) == "|" then
      count = count + 1
    end
  end
  return count + 1
end

function M.sort_by_column()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines < 2 then return end

  local col_idx = get_column_index()
  local header = lines[1]
  local data_lines = {}

  for i = 2, #lines do
    table.insert(data_lines, lines[i])
  end

  table.sort(data_lines, function(a, b)
    local a_cols = vim.split(a, " | ")
    local b_cols = vim.split(b, " | ")
    local a_val = vim.trim(a_cols[col_idx] or "")
    local b_val = vim.trim(b_cols[col_idx] or "")
    return a_val < b_val
  end)

  local sorted = { header }
  for _, line in ipairs(data_lines) do
    table.insert(sorted, line)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted)
end

function M.align_csv()
  local original_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(original_buf, 0, -1, false)
  local text = table.concat(lines, "\n")
  local rows = parse_csv(text)

  if #rows == 0 then return end

  local max_cols = {}
  for _, row in ipairs(rows) do
    for i, field in ipairs(row) do
      local clean_field = field:gsub("\n", " "):gsub("\r", "")
      local display_width = vim.fn.strdisplaywidth(clean_field)
      max_cols[i] = math.max(max_cols[i] or 0, display_width)
    end
  end

  local aligned = {}
  for _, row in ipairs(rows) do
    local formatted = {}
    for i, field in ipairs(row) do
      local clean_field = field:gsub("\n", " "):gsub("\r", "")
      local width = max_cols[i] or 0
      local display_width = vim.fn.strdisplaywidth(clean_field)
      local padding = string.rep(" ", width - display_width)
      table.insert(formatted, clean_field .. padding)
    end
    table.insert(aligned, table.concat(formatted, " | "))
  end

  -- Create new buffer with aligned content
  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, aligned)
  vim.api.nvim_win_set_buf(0, new_buf)
  vim.bo[new_buf].filetype = "csv-aligned"
  vim.bo[new_buf].buftype = "nofile"
end

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.csv",
  callback = function()
    M.align_csv()

    -- Fast column navigation
    vim.keymap.set("n", "<C-Left>", "F|", { buffer = true })
    vim.keymap.set("n", "<C-Right>", "f|l", { buffer = true })
    vim.keymap.set("n", "<S-Left>", "0", { buffer = true })
    vim.keymap.set("n", "<S-Right>", "$", { buffer = true })

    -- Sort by column
    vim.keymap.set("n", "<C-s>", M.sort_by_column, { buffer = true })

    -- Performance settings
    vim.opt_local.wrap = false
    vim.opt_local.sidescroll = 1
    vim.opt_local.syntax = "off"
    vim.opt_local.lazyredraw = true
    vim.opt_local.ttyfast = true
    vim.opt_local.regexpengine = 1
  end,
})

return M
