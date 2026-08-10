local buf_large_lsp = vim.api.nvim_create_augroup("buf_large", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPre", "LspAttach" }, {
  callback = function(event)
    local bufnr = event.buf
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local ok, stats = pcall(vim.uv.fs_stat, buf_name)

    local MAX_FILE_SIZE_BYTES = 700000 -- 700KB threshold for performance optimization

    if ok and stats and (stats.size > MAX_FILE_SIZE_BYTES) then
      vim.notify("Buffer " .. buf_name .. " too big, disabling features for performance...", vim.log.levels.WARN)
      -- local client = vim.lsp.get_client_by_id(event.data.client_id)
      -- client.server_capabilities.semanticTokensProvider = nil
      vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = bufnr }))
      pcall(vim.diagnostic.enable, false, bufnr)
      vim.b[bufnr].ministatusline_disable = true
      vim.b[bufnr].miniindentscope_disable = true
      vim.b[bufnr].loaded_matchparen = 1
      vim.b[bufnr].completion = false
      vim.bo[bufnr].swapfile = false
      vim.bo[bufnr].bufhidden = "unload"
      for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.wo[win].spell = false
        vim.wo[win].cursorcolumn = false
        vim.wo[win].cursorline = false
        vim.wo[win].foldenable = false
        vim.wo[win].conceallevel = 0
      end
      local ignored = "CursorHoldI,CursorMovedI,CursorMoved,FileType"
      vim.api.nvim_create_autocmd("WinEnter", {
        buffer = bufnr,
        group = buf_large_lsp,
        callback = function()
          vim.opt.eventignore:append(ignored)
        end,
      })
      vim.api.nvim_create_autocmd("WinLeave", {
        buffer = bufnr,
        group = buf_large_lsp,
        callback = function()
          vim.opt.eventignore:remove(ignored)
        end,
      })
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
