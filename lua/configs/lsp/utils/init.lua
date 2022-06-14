local status_ok, lspsignature = pcall(require, "lsp_signature")
if not status_ok then
  error("Failed loading lsp_signature")
  return
end
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  error("Failed loading cmp_nvim_lsp")
  return
end

local M = {}

M.lsp_handlers = function()
  local function lspSymbol(name, icon)
    local hl = "DiagnosticSign" .. name
    vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
  end

  lspSymbol("Error", "")
  lspSymbol("Info", "")
  lspSymbol("Hint", "")
  lspSymbol("Warn", "")

  vim.diagnostic.config({
    virtual_text = {
      source = "always",
      severity = vim.diagnostic.severity.ERROR,
      spacing = 1,
    },
    update_in_insert = true,
    underline = false,
    severity_sort = true,
    float = {
      source = "always",
      header = "",
      prefix = "",
      border = "single",
    },
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
  })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "single",
  })

  -- suppress error messages from lang servers
  vim.notify = function(msg, log_level)
    if msg:match("exit code") then
      return
    end
    if log_level == vim.log.levels.ERROR then
      vim.api.nvim_err_writeln(msg)
    else
      vim.api.nvim_echo({ { msg } }, true, {})
    end
  end
end
function M.lsp_keymaps(bufnr)
  map("n", "<space>e", vim.diagnostic.open_float, { desc = "View diagnostic" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Next diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Previous diagnostic" })
  map("n", "<space>cq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
  bmap(bufnr, "n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  bmap(bufnr, "n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
  bmap(bufnr, "n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
  bmap(bufnr, "n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })
  bmap(bufnr, "n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
  bmap(bufnr, "i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
  bmap(bufnr, "n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace" })
  bmap(bufnr, "n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove worksapce" })
  bmap(bufnr, "n", "<space>wl", vim.lsp.buf.list_workspace_folders, { desc = "List workspace folders" })
  bmap(bufnr, "n", "<space>D", vim.lsp.buf.type_definition, { desc = "View type definition" })
  bmap(bufnr, "n", "<space>rn", vim.lsp.buf.rename, { desc = "Rename" })
  bmap(bufnr, "n", "<space>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
  bmap(bufnr, "n", "<space>cf", vim.lsp.buf.formatting, { desc = "Format current buffer" })
  bmap(bufnr, "n", "gr", vim.lsp.buf.references, { desc = "Show references" })
end

function M.lsp_highlight_document(client)
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      augroup lsp_document_highlight
        au!
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end
end

function M.lsp_signature(bufnr)
  lspsignature.on_attach({
    bind = true, -- This is mandatory, otherwise border config won"t get registered.
    handler_opts = {
      border = "single",
    },
    hint_prefix = " ",
    max_height = 8,
  }, bufnr)
end
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities)
M.flags = {
  debounce_text_changes = 150,
}

return M
