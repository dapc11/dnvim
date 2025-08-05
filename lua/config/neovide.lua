vim.o.guifont = "JetBrains Mono NL:h14"
vim.api.nvim_set_keymap("n", "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", {})
vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", {})
vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", {})

vim.g.neovide_scale_factor = 1
vim.g.neovide_confirm_quit = true
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animation_length = 0.0
vim.g.neovide_scroll_animation_length = 0.0

-- vim.api.nvim_set_keymap('v', '<sc-c>', '"+y', {noremap = true})
-- vim.api.nvim_set_keymap('n', '<sc-v>', 'l"+P', {noremap = true})
-- vim.api.nvim_set_keymap('v', '<sc-v>', '"+P', {noremap = true})
-- vim.api.nvim_set_keymap('i', '<sc-v>', '<ESC>l"+Pli', {noremap = true})
-- vim.api.nvim_set_keymap('t', '<sc-v>', '<C-\\><C-n>"+Pi', {noremap = true})

vim.keymap.set("n", "<SC-s>", ":w<CR>") -- Save
vim.keymap.set("v", "<SC-c>", '"+y') -- Copy
vim.keymap.set("n", "<SC-v>", '"+P') -- Paste normal mode
vim.keymap.set("v", "<SC-v>", '"+P') -- Paste visual mode
vim.keymap.set("c", "<SC-v>", "<C-R>0") -- Paste command mode
vim.keymap.set("i", "<SC-v>", '<ESC>l"+Pli') -- Paste insert mode

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<SC-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
