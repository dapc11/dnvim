local csv = require("user.csv")
csv.align_csv()

vim.keymap.set("n", "<C-Left>", "F|", { buffer = true })
vim.keymap.set("n", "<C-Right>", "f|l", { buffer = true })
vim.keymap.set("n", "<S-Left>", "0", { buffer = true })
vim.keymap.set("n", "<S-Right>", "$", { buffer = true })
vim.keymap.set("n", "<C-s>", csv.sort_by_column, { buffer = true })

vim.opt_local.wrap = false
vim.opt_local.sidescroll = 1
vim.opt_local.syntax = "off"
vim.opt_local.lazyredraw = true
vim.opt_local.ttyfast = true
vim.opt_local.regexpengine = 1
