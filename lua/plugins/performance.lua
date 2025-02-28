local buf_large_lsp = vim.api.nvim_create_augroup("buf_large", { clear = true })
local buf_large_common = vim.api.nvim_create_augroup("buf_large_file", { clear = true })

vim.api.nvim_create_autocmd({ "LspAttach", "BufReadPost" }, {
  callback = function(_)
    local bufnr = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local ok, stats = pcall(vim.loop.fs_stat, buf_name)

    if ok and stats and (stats.size > 400000) then
      print("Buffer " .. buf_name .. " too big, disabling LSP and Diagnostics...")
      -- local client = vim.lsp.get_client_by_id(event.data.client_id)
      -- client.server_capabilities.semanticTokensProvider = nil
      vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = bufnr }))
      pcall(vim.diagnostic.enable, false, bufnr)
    end
  end,
  group = buf_large_lsp,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufEnter" }, {
  callback = function(event)
    local buf_name = vim.api.nvim_buf_get_name(event.buf)
    local ok, stats = pcall(vim.loop.fs_stat, buf_name)

    if ok and stats and (stats.size > 10485760) then
      print("Buffer " .. buf_name .. " too big, performance focus!")
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.bufhidden = "unload"
      vim.opt_local.buftype = "nowrite"
      vim.opt_local.undolevels = -1
      vim.cmd([[set eventignore+=FileType]])
    else
      vim.cmd([[set eventignore-=FileType]])
    end
  end,
  group = buf_large_common,
})

return {
  {
    "stevearc/profile.nvim",
    event = "VeryLazy",
  },
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = lazyfile,
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
  },
}
