local map = require("util").map
local function opts(desc)
  return { buffer = true, noremap = true, silent = true, desc = "LSP: " .. (desc or "") }
end

vim.diagnostic.config({
  underline = false,
  virtual_lines = false
})

for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end

vim.lsp.config("*", {
  root_markers = { ".git" },
})

vim.lsp.enable({ "luals", "pyright", "gopls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    map("n", "gd", function() Snacks.picker.lsp_definitions() end, opts("Goto Definition"))
    map("n", "<leader>cf", vim.lsp.buf.format, opts("Format"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
    map("n", "<leader>cd", vim.diagnostic.open_float, opts("Show Diagnostic"))
    map("n", "]d", vim.diagnostic.goto_next, opts("Next Diagnostic"))
    map("n", "[d", vim.diagnostic.goto_prev, opts("Prev Diagnostic"))
    map("i", "<C-h>", vim.lsp.buf.signature_help, opts("Show Signature"))
    map("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))

    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    if client.supports_method("textDocument/documentHighlight") then
      local autocmd = vim.api.nvim_create_autocmd
      local augroup = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })

      vim.api.nvim_clear_autocmds({ buffer = args.buf, group = augroup })

      autocmd({ "CursorHold" }, {
        group = augroup,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      autocmd({ "CursorMoved" }, {
        group = augroup,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if not client:supports_method("textDocument/willSaveWaitUntil")
      and client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
  group = vim.api.nvim_create_augroup("my.lsp", {}),
})
