vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "fugitive",
    "fugitiveblame",
    "Jaq",
    "qf",
    "fzf",
    "help",
    "man",
    "dap-repl",
    "DressingSelect",
    "OverseerList",
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

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*.lua" },
  callback = function(_)
    require("util").format("stylua --search-parent-directories -")
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*.py" },
  callback = function(_)
    require("util").format("black --quiet -")
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*.go" },
  callback = function(_)
    require("go.format").gofmt()
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = { "*.tpl", "*.yaml", "*.yml" },
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
    vim.diagnostic.disable(bufnr)
    require("lualine").refresh()

    vim.cmd([[ if search('{{.*}}', 'nw') | setlocal filetype=gotmpl | endif]])
  end,
})

local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "BufReadPost" }, {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))

    if ok and stats and (stats.size > 400000) then
      vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
      vim.diagnostic.disable(bufnr)
      vim.opt_local.spell = false
      require("lualine").refresh()
    end
  end,
  group = aug,
  pattern = "*",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "COMMIT_EDITMSG" },
  callback = function()
    -- local bufnr = vim.api.nvim_get_current_buf()
    -- vim.api.nvim_create_autocmd("BufWritePost", {
    --   bufnr = bufnr,
    --   callback = vim.schedule_wrap(function()
    --     vim.api.nvim_buf_delete(bufnr, {})
    --   end),
    -- })
    vim.keymap.set("n", "<c-c><c-c>", "<cmd>wq<cr>", { noremap = true, buffer = true })
    vim.keymap.set("i", "<c-c><c-c>", "<esc><cmd>wq<cr>", { noremap = true, buffer = true })
  end,
})
