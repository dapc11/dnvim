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

-- Command typo fixes
local cmds = {
  { "W", "w" },
  { "Wq", "wq" },
  { "Wqa", "wqa" },
  { "WQ", "wq" },
  { "Q", "q" },
  { "Qa", "qa" },
  { "Qw", "wq" },
}
for _, cmd in ipairs(cmds) do
  vim.api.nvim_create_user_command(cmd[1], cmd[2], {})
end

-- Force variants using command abbreviations
vim.cmd([[
  cnoreabbrev W! w!
  cnoreabbrev Wq! wq!
  cnoreabbrev WQ! wq!
  cnoreabbrev Q! q!
  cnoreabbrev Qw! wq!
]])
