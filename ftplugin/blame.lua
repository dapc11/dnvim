vim.keymap.set("n", "gf", function()
  vim.api.nvim_exec("tab Git show " .. vim.call("expand", "<cword>"), true)
end, { desc = "Find Usages", buffer = true })
