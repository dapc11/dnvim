vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "" },
  callback = function()
    local buf_ft = vim.bo.filetype
    local function tableContains(table, element)
      for _, value in pairs(table) do
        if value == element then
          return true
        end
      end
      return false
    end
    if buf_ft == "" or buf_ft == nil or tableContains(require("util.common").ignored_filetypes, buf_ft) then
      vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      nnoremap <silent> <buffer> <esc> :close<CR>
      nnoremap <silent> <buffer> <c-j> j<CR>
      nnoremap <silent> <buffer> <c-k> k<CR>
      set nobuflisted
    ]])
    end
  end,
})

vim.api.nvim_create_autocmd({ "DiffUpdated" }, {
  pattern = { "" },
  callback = function()
    if vim.wo.diff then
      vim.diagnostic.disable()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.keymap.set("n", "o", function()
        return ":diffget //2<CR>"
      end, { expr = true, silent = true, buffer = bufnr })

      vim.keymap.set("n", "t", function()
        return ":diffget //3<CR>"
      end, { expr = true, silent = true, buffer = bufnr })
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
  callback = function(_)
    if vim.bo.filetype == "yaml" then
      local bufnr = vim.api.nvim_get_current_buf()
      vim.diagnostic.disable(bufnr)
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = { "*.tpl", "*.yaml", "*.yml" },
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
    vim.diagnostic.disable(bufnr)

    vim.cmd([[ if search('{{.*end.*}}', 'nw') | setlocal filetype=gotmpl | endif]])
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = { "*.txt" },
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
    vim.diagnostic.disable(bufnr)

    vim.cmd([[ if search('{"version"', 'nw') | setlocal filetype=json | endif]])
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "COMMIT_EDITMSG" },
  callback = function()
    vim.keymap.set("n", "<c-c><c-c>", "<cmd>wq<CR>", { noremap = true, buffer = true })
    vim.keymap.set("i", "<c-c><c-c>", "<esc><cmd>wq<CR>", { noremap = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua" },
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*" },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
