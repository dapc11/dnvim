local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope telescope-yaml<cr>", { desc = "YAML key", buffer = bufnr })
