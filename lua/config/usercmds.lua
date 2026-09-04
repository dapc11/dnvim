vim.api.nvim_create_user_command("CopyPath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied to clipboard: " .. path)
end, { desc = "Copy full file path to clipboard" })

vim.api.nvim_create_user_command("CopyCmd", function(x)
  vim.fn.setreg("+", vim.fn.execute(x.args))
end, { nargs = 1 })

vim.api.nvim_create_user_command("CopyMsg", function()
  local lines = vim.split(vim.fn.execute("messages"), "\n")
  -- :messages output is fenced by blank lines, which would show up as stray
  -- empty lines when the register is put back into a buffer.
  while lines[1] == "" do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  if #lines == 0 then
    print("No messages to copy")
    return
  end
  vim.fn.setreg("+", lines, "l")
  print(("Copied %d message line(s) to clipboard"):format(#lines))
end, { desc = "Copy :messages output to clipboard" })

vim.api.nvim_create_user_command("Dump", function(x)
  local output = vim.fn.execute(x.args)
  vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
end, { nargs = "+", desc = "Dump output of a command at the cursor position" })

vim.api.nvim_create_user_command("Trim", function()
  -- Remove trailing whitespace
  vim.cmd([[%s/\s\+$//e]])
end, { desc = "Trim trailing whitespace and ensure single blank line at end" })

-- Command typo fixes (abbreviations handle both :W and :W!)
--
-- Guarded with <expr> so they only fire when the abbreviation is the entire
-- command line of a ":" command. Unguarded, cnoreabbrev rewrites the text
-- anywhere a bare "W" appears, which corrupts arguments such as ":e W.txt"
-- and ":CopyCmd W".
local abbrevs = { W = "w", Wq = "wq", Wqa = "wqa", WQ = "wq", Q = "q", Qa = "qa", Qw = "wq" }
for from, to in pairs(abbrevs) do
  for _, bang in ipairs({ "", "!" }) do
    local lhs, rhs = from .. bang, to .. bang
    vim.cmd(
      string.format(
        "cnoreabbrev <expr> %s (getcmdtype() ==# ':' && getcmdline() ==# %s) ? %s : %s",
        lhs,
        vim.fn.string(lhs),
        vim.fn.string(rhs),
        vim.fn.string(lhs)
      )
    )
  end
end
