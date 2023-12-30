local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()
local cmp_format = require("lsp-zero").cmp_format()

require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "luasnip" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-n>"] = cmp_action.luasnip_jump_forward(),
    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<Tab>"] = cmp_action.luasnip_supertab(),
    ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
  }),
  formatting = cmp_format,
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
})
local lsp_zero = require("lsp-zero")

local function opts(desc, bufnr)
  return { buffer = bufnr, remap = false, desc = desc }
end

-- stylua: ignore
lsp_zero.on_attach(function(_, bufnr)
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Goto definition", bufnr))
  vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts("LSP References", bufnr))
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts("", bufnr))
  vim.keymap.set("n", "<leader>cs", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace Symbols", bufnr))
  vim.keymap.set("n", "<leader>cd", function() vim.diagnostic.open_float() end, opts("Open Float", bufnr))
  vim.keymap.set("n", "<leader>cf", function() require("conform").format() end, opts("Format", bufnr))
  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts("Code Action", bufnr))
  vim.keymap.set("n", "<leader>cr", function() vim.lsp.buf.rename() end, opts("Rename Symbol", bufnr))
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Goto Next Diagnostic", bufnr))
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Goto Prev Diagnostic", bufnr))
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts("", bufnr))
end)

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "golangci_lint_ls", "lua_ls", "pylsp" },
  handlers = {
    -- Exclude lsp setup by defining it as follows: tsserver = lsp_zero.noop
    lsp_zero.default_setup,
    gopls = function()
      require("lspconfig").gopls.setup(require("plugins.language_servers.gopls"))
    end,
    lua_ls = function()
      require("lspconfig").lua_ls.setup(require("plugins.language_servers.lua_ls"))
    end,
  },
})

vim.diagnostic.config({
  virtual_text = false,
})
