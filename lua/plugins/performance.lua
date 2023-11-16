local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "BufReadPost" }, {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))

    if ok and stats and (stats.size > 400000) then
      vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
      vim.diagnostic.disable(bufnr)
      vim.opt_local.spell = false
    end
  end,
  group = aug,
  pattern = "*",
})

vim.cmd([[
augroup LargeFile
let g:large_file = 10485760 " 10MB

" Set options:
"   eventignore+=FileType (no syntax highlighting etc
"   assumes FileType always on)
"   noswapfile (save copy of file)
"   bufhidden=unload (save memory when other file is viewed)
"   buftype=nowritefile (is read-only)
"   undolevels=-1 (no undo possible)
au BufReadPre *
  \ let f=expand("<afile>") |
  \ if getfsize(f) > g:large_file |
    \ set eventignore+=FileType |
    \ setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 |
  \ else |
    \ set eventignore-=FileType |
  \ endif
augroup END
]])

return {
  { "LunarVim/bigfile.nvim" },
  "stevearc/profile.nvim",
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
  },
}
