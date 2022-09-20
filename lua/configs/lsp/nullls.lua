local M = {}

function M.config()
  ------ Setup formatting.
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    return
  end

  local enable_ls = function(bufnr)
    return vim.api.nvim_buf_line_count(bufnr) < 2000
  end

  local write_good = null_ls.builtins.diagnostics.write_good.with({
    filetypes = { "markdown", "text" },
    runtime_condition = function(params)
      return enable_ls(params.bufnr)
    end,
  })
  local black = null_ls.builtins.formatting.black
  local pylint = null_ls.builtins.diagnostics.pylint.with({
    filetypes = { "python" },
    extra_args = {
      "-d",
      "R0801,W1508,C0114,C0115,C0116,C0301,W0611,W1309",
    },
  })
  local flake8 = null_ls.builtins.diagnostics.flake8.with({
    filetypes = { "python" },
    extra_args = {
      "--per-file-ignores=**/test_*:D100,D103",
    },
  })
  local isort = null_ls.builtins.formatting.isort
  local gofmt = null_ls.builtins.formatting.gofmt
  local goimports = null_ls.builtins.formatting.goimports
  local stylua = null_ls.builtins.formatting.stylua

  -- register any number of sources simultaneously
  local sources = {
    null_ls.builtins.diagnostics.trail_space,
    null_ls.builtins.code_actions.gitsigns,
    stylua,
    black,
    gofmt,
    goimports,
    write_good,
    pylint,
    flake8,
    isort,
    null_ls.builtins.diagnostics.golangci_lint,
    null_ls.builtins.code_actions.refactoring,
  }

  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  require("lsp.utils").lsp_handlers()
  null_ls.setup({
    sources = sources,
    diagnostics_format = "[#{c}] #{m}",
    should_attach = function(bufnr)
      return not vim.api.nvim_buf_get_name(bufnr):match("^NvimTree")
    end,
    on_attach = function(client, bufnr)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Show tooltip" })
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<space>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        { desc = "Code actions" }
      )
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<space>cf",
        "<cmd>lua vim.lsp.buf.format({async = true})<CR>",
        { desc = "Format file" }
      )
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end,
  })
end

return M
