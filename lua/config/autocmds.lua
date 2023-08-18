vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "fugitive",
    "fugitiveblame",
    "Jaq",
    "qf",
    "fzf",
    "help",
    "man",
    "lspinfo",
    "DressingSelect",
    "OverseerList",
    "tsplayground",
    "Markdown",
    "git",
    "PlenaryTestPopup",
    "lspinfo",
    "notify",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      nnoremap <silent> <buffer> <esc> :close<CR>
      set nobuflisted
    ]])
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "" },
  callback = function()
    local buf_ft = vim.bo.filetype
    if buf_ft == "" or buf_ft == nil then
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

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "DiffviewFileHistory",
    "DiffviewFiles",
  },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :DiffviewClose<CR>
      nnoremap <silent> <buffer> <esc> :DiffviewClose<CR>
      set nobuflisted
    ]])
  end,
})

vim.api.nvim_create_autocmd({ "DiffUpdated" }, {
  pattern = { "" },
  callback = function()
    if vim.wo.diff then
      vim.diagnostic.disable()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.keymap.set("n", "2", function()
        return ":diffget //2<CR>"
      end, { expr = true, silent = true, buffer = bufnr })

      vim.keymap.set("n", "3", function()
        return ":diffget //3<CR>"
      end, { expr = true, silent = true, buffer = bufnr })
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
  -- or vim.api.nvim_create_autocmd({"BufNew", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT"}, {
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.disable(bufnr)
  end,
})

vim.api.nvim_create_autocmd({ "BufWrite" }, {
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.enable(bufnr)
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})
vim.cmd([[autocmd BufNewFile,BufRead *.yaml,*.tpl,*.yml if search('{{.*}}', 'nw') | setlocal filetype=gotmpl | endif]])
