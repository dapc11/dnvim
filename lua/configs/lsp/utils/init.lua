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
    underline = true,
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
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "gd",
    "<cmd>Telescope lsp_definitions<CR>",
    { noremap = true, silent = true, desc = "Goto definition" }
  )
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "gD",
    "<cmd>Telescope lsp_declarations<CR>",
    { noremap = true, silent = true, desc = "Goto declaration" }
  )
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "gi",
    "<cmd>Telescope lsp_implementations<CR>",
    { noremap = true, silent = true, desc = "Goto implementation" }
  )
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "gr",
    "<cmd>Telescope lsp_references<CR>",
    { noremap = true, silent = true, desc = "Show references" }
  )
  vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "View diagnostic" })
  vim.keymap.set("n", ">d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
  vim.keymap.set("n", "<d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
  vim.keymap.set("n", "<space>cl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information", buffer = bufnr })
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help", buffer = bufnr })
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help", buffer = bufnr })
  vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace", buffer = bufnr })
  vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove worksapce", buffer = bufnr })
  vim.keymap.set(
    "n",
    "<space>wl",
    vim.lsp.buf.list_workspace_folders,
    { desc = "List workspace folders", buffer = bufnr }
  )
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { desc = "View type definition", buffer = bufnr })
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = bufnr })
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { desc = "Code actions", buffer = bufnr })
  -- vim.keymap.set("n", "<space>cf", vim.lsp.buf.formatting, { desc = "Format current buffer", buffer = bufnr })
  -- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition", buffer = bufnr })
  -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation", buffer = bufnr })
  -- vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references", buffer = bufnr })
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
end

function M.attach_navic(client, bufnr)
  vim.g.navic_silence = false
  local ok, navic = pcall(require, "nvim-navic")
  if not ok then
    print("Failed loading navic")
    return
  end
  navic.attach(client, bufnr)
end

function M.lsp_highlight_document(client)
  if client.server_capabilities.document_highlight then
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

local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok then
  error("Failed loading cmp_nvim_lsp")
  return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = cmp_nvim_lsp.update_capabilities(M.capabilities)
M.flags = {
  debounce_text_changes = 150,
}

return M
