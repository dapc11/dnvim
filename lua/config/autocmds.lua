vim.api.nvim_create_autocmd("FileType", {
  pattern = require("util.common").ignored_filetypes,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.opt.colorcolumn = "0"
    vim.keymap.set("n", "q", "<cmd>close<CR>", { silent = true, buffer = true })
    vim.keymap.set("n", "<esc>", "<cmd>close<CR>", { silent = true, buffer = true })
    vim.keymap.set("n", "<c-j>", "j<CR>", { silent = true, buffer = true })
    vim.keymap.set("n", "<c-k>", "k<CR>", { silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("DiffUpdated", {
  pattern = "",
  callback = function(_)
    if vim.wo.diff then
      vim.diagnostic.disable()
      vim.keymap.set("n", "o", "<cmd>diffget //2<CR>", { expr = true, silent = true, buffer = true })
      vim.keymap.set("n", "t", "<cmd>diffget //3<CR>", { expr = true, silent = true, buffer = true })
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "yaml",
  callback = function(event)
    vim.diagnostic.disable(event.buf)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = { "*.tpl", "*.yaml", "*.yml" },
  callback = function(event)
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = event.buf }))
    vim.diagnostic.disable(event.buf)

    vim.cmd([[ if search('{{.*end.*}}', 'nw') | setlocal filetype=gotmpl | endif]])
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = "*.txt",
  callback = function(event)
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = event.buf }))
    vim.diagnostic.disable(event.buf)

    vim.cmd([[ if search('{"version"', 'nw') | setlocal filetype=json | endif]])
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.keymap.set("n", "<c-c><c-c>", "<cmd>wq<CR>", { noremap = true, buffer = true })
    vim.keymap.set("i", "<c-c><c-c>", "<esc><cmd>wq<CR>", { noremap = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- always open quickfix window automatically.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
  pattern = { "[^l]*" },
  command = "cwindow",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_line_count(bufnr) > 5000 then
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
