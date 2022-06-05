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
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<space>cq", vim.diagnostic.setloclist, opts)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "<space>cf", vim.lsp.buf.formatting, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
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
