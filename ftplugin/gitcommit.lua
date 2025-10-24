vim.opt_local.colorcolumn = "72"

-- Highlight subject line if too long
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
  buffer = 0,
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    if #first_line > 50 then
      vim.fn.matchadd("Error", "\\%1l\\%>50c.*")
    else
      vim.fn.clearmatches()
    end
  end
})

local function format_commit_message()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local formatted = {}
  
  for i, line in ipairs(lines) do
    if i == 1 then
      -- Subject line: don't modify, just keep as is
      table.insert(formatted, line)
    elseif line == "" then
      -- Keep blank lines
      table.insert(formatted, line)
    elseif line:match("^Jira:") or line:match("^PRI:") or line:match("^Tracking%-Id:") or line:match("Other_change") or line:match("Requirement") then
      -- Don't format metadata lines
      table.insert(formatted, line)
    else
      -- Body lines: wrap at 72 chars
      while #line > 72 do
        local break_pos = 72
        -- Try to break at word boundary
        for j = 72, 1, -1 do
          if line:sub(j, j) == ' ' then
            break_pos = j - 1
            break
          end
        end
        table.insert(formatted, line:sub(1, break_pos))
        line = line:sub(break_pos + 2) -- Skip the space
      end
      if #line > 0 then
        table.insert(formatted, line)
      end
    end
  end
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
end

vim.keymap.set('n', '<leader>gc', '<cmd>GpGit<cr>', { buffer = true, desc = 'Generate commit with GP' })
vim.keymap.set('n', '<leader>cf', format_commit_message, { buffer = true, desc = 'Format commit message' })

