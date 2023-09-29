local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set({ "v", "n" }, "<leader>cf", ":%!jq '.'", { desc = "Format", buffer = bufnr })
