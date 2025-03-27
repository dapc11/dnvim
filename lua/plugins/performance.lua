local buf_large_lsp = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre", "LspAttach" }, {
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local ok, stats = pcall(vim.loop.fs_stat, buf_name)

    if ok and stats and (stats.size > 400000) then
      print("Buffer " .. buf_name .. " too big, disabling features for performance...")
      -- local client = vim.lsp.get_client_by_id(event.data.client_id)
      -- client.server_capabilities.semanticTokensProvider = nil
      vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = bufnr }))
      pcall(vim.diagnostic.enable, false, bufnr)
      vim.b.ministatusline_disable = true
      vim.b.miniindentscope_disable = true
      vim.b.loaded_matchparen = 1
      vim.b.completion = false
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.bufhidden = "unload"
      vim.opt_local.buftype = "nowrite"
      vim.cmd([[
      autocmd WinEnter <buffer> set eventignore+=CursorHoldI,CursorMovedI,CursorMoved,FileType
      autocmd WinLeave <buffer> set eventignore-=CursorHoldI,CursorMovedI,CursorMoved,FileType
      autocmd! * <buffer>
      set nocursorcolumn nocursorline
      set nofoldenable
      set conceallevel=0
      set updatetime=100
      set lazyredraw
      ]])
    end
  end,
  group = buf_large_lsp,
})

return {
  {
    "stevearc/profile.nvim",
    event = "VeryLazy",
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    lazy = false, -- always load to make sure than old LSPs are shutdown
  },
}
