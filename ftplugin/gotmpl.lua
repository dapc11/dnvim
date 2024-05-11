vim.keymap.set("n", "gr", function()
  vim.cmd('noau normal! "vyi"')
  require("fzf-lua").grep_project({ search = 'include "' .. vim.fn.getreg("v") .. '"' })
end, { desc = "Find References", buffer = true })

vim.keymap.set("n", "gd", function()
  vim.cmd('noau normal! "vyi"')
  require("fzf-lua").grep_project({ search = 'define "' .. vim.fn.getreg("v") .. '"' })
end, { desc = "Goto Definition", buffer = true })
