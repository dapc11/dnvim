vim.api.nvim_create_user_command("CopyCmd", function(x)
  vim.fn.setreg("+", vim.fn.execute(x.args))
end, { nargs = 1 })

vim.api.nvim_create_user_command("Dump", function(x)
  local output = vim.fn.execute(x.args)
  vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
end, { nargs = "+", desc = "Dump output of a command at the cursor position" })

vim.api.nvim_create_user_command("Trim", function()
  -- Remove trailing whitespace
  vim.cmd([[%s/\s\+$//e]])
end, { desc = "Trim trailing whitespace and ensure single blank line at end" })
