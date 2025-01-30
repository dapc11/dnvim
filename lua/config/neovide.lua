vim.o.guifont = "Fira Code:h13"
vim.api.nvim_set_keymap("n", "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", {})
vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", {})
vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", {})

vim.g.neovide_scale_factor = 1
vim.g.neovide_confirm_quit = true
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animation_length = 0.1
vim.g.neovide_scroll_animation_length = 0.2

vim.api.nvim_set_keymap('v', '<sc-c>', '"+y', {noremap = true})
vim.api.nvim_set_keymap('n', '<sc-v>', 'l"+P', {noremap = true})
vim.api.nvim_set_keymap('v', '<sc-v>', '"+P', {noremap = true})
vim.api.nvim_set_keymap('i', '<sc-v>', '<ESC>l"+Pli', {noremap = true})
vim.api.nvim_set_keymap('t', '<sc-v>', '<C-\\><C-n>"+Pi', {noremap = true})
