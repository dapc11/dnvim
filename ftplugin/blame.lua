vim.keymap.set("n", "gf", function()
  vim.api.nvim_exec2("tab Git show " .. vim.fn.expand("<cword>"), true)
end, { desc = "Find Usages", buffer = true })
