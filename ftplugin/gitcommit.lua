vim.opt_local.colorcolumn = "72"

-- Highlight subject line if too long
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  buffer = 0,
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    if #first_line > 50 then
      vim.fn.matchadd("Error", "\\%1l\\%>50c.*")
    else
      vim.fn.clearmatches()
    end
  end,
})

local function is_trailer(line)
  return line:match("^Jira:")
    or line:match("^PRI:")
    or line:match("^Tracking%-Id:")
    or line:match("^Change%-Id:")
    or line:match("^Other_change")
    or line:match("^Requirement:")
    or line:match("^Troublereport:")
    or line:match("^Vulnerability:")
end

local function wrap_line(text, width)
  local result = {}
  while #text > width do
    local break_pos = width
    for j = width, 1, -1 do
      if text:sub(j, j) == " " then
        break_pos = j
        break
      end
    end
    if break_pos == width and text:sub(break_pos, break_pos) ~= " " then
      -- No space found within width — don't break the word
      for j = width + 1, #text do
        if text:sub(j, j) == " " then
          break_pos = j
          break
        end
      end
      if break_pos == width then
        break -- single word longer than width, give up
      end
    end
    table.insert(result, text:sub(1, break_pos - 1))
    text = text:sub(break_pos + 1)
  end
  if #text > 0 then
    table.insert(result, text)
  end
  return result
end

local function format_commit_message()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local formatted = {}

  -- Find where git comments start
  local msg_end = #lines
  for i, line in ipairs(lines) do
    if line:match("^# ") then
      msg_end = i - 1
      break
    end
  end

  -- Collect paragraphs from the body (skip subject + blank line)
  local i = 1
  -- Subject line
  if i <= msg_end then
    table.insert(formatted, (lines[i]:gsub("%s+$", "")))
    i = i + 1
  end

  -- Blank line after subject
  if i <= msg_end and lines[i]:match("^%s*$") then
    table.insert(formatted, "")
    i = i + 1
  end

  -- Body: join paragraph lines, then re-wrap
  local paragraph = {}
  while i <= msg_end do
    local line = lines[i]:gsub("%s+$", "")
    if line == "" then
      -- Flush current paragraph
      if #paragraph > 0 then
        local joined = table.concat(paragraph, " ")
        vim.list_extend(formatted, wrap_line(joined, 72))
        paragraph = {}
      end
      table.insert(formatted, "")
    elseif is_trailer(line) then
      -- Flush paragraph before trailers
      if #paragraph > 0 then
        local joined = table.concat(paragraph, " ")
        vim.list_extend(formatted, wrap_line(joined, 72))
        paragraph = {}
      end
      table.insert(formatted, line)
    else
      table.insert(paragraph, line)
    end
    i = i + 1
  end
  -- Flush remaining paragraph
  if #paragraph > 0 then
    local joined = table.concat(paragraph, " ")
    vim.list_extend(formatted, wrap_line(joined, 72))
  end

  -- Collapse consecutive blank lines
  local deduped = {}
  for _, l in ipairs(formatted) do
    if l ~= "" or (#deduped > 0 and deduped[#deduped] ~= "") then
      table.insert(deduped, l)
    end
  end

  -- Append git comment lines unchanged
  for j = msg_end + 1, #lines do
    table.insert(deduped, lines[j])
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, deduped)
end

vim.keymap.set("n", "<leader>gc", "<cmd>GpGit<cr>", { buffer = true, desc = "Generate commit with GP" })
vim.keymap.set("n", "<leader>cf", format_commit_message, { buffer = true, desc = "Format commit message" })
