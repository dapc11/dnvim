local map = require("util").map
local function opts(desc)
  return { buffer = true, noremap = true, silent = true, desc = "LSP: " .. (desc or "") }
end

local icons = require("config.icons")
vim.diagnostic.config({
  underline = true,
  virtual_lines = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
})

vim.lsp.config("*", {
  root_markers = { ".git" },
})

vim.lsp.enable({ "luals", "pyright", "gopls", "yamlls" })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local fzf = require("fzf-lua")
    map("n", "grs", fzf.lsp_document_symbols, opts("Find Symbols"))
    map("n", "grr", fzf.lsp_references, opts("Find References"))
    map("n", "gd", fzf.lsp_definitions, opts("Goto Definition"))
    map("n", "<leader>cf", vim.lsp.buf.format, opts("Format"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
    map("n", "<leader>fd", vim.diagnostic.open_float, opts("Find Diagnostic"))
    map("n", "<leader>fD", fzf.diagnostics_workspace, opts("Find Workspace Diagnostic"))
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts("Next Diagnostic"))
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts("Prev Diagnostic"))
    map("i", "<C-h>", vim.lsp.buf.signature_help, opts("Show Signature"))
    map("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    if
        not client:supports_method("textDocument/willSaveWaitUntil")
        and client:supports_method("textDocument/formatting")
    then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
    client.server_capabilities.semanticTokensProvider = nil
  end,
  group = vim.api.nvim_create_augroup("my.lsp", {}),
})
