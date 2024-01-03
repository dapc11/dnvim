local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()
local cmp_format = require("lsp-zero").cmp_format()

require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "buffer" },
    { name = "luasnip" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    -- Ctrl+Space to trigger completion menu
    ["<C-Space>"] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ["<Tab>"] = cmp_action.luasnip_jump_forward(),
    ["<S-Tab>"] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
  }),
  formatting = cmp_format,
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
})
local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(_, bufnr)
  require("util").lsp_keymaps(bufnr)
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
      require("neodev").setup()
      require("lspconfig").lua_ls.setup(require("plugins.language_servers.lua_ls"))
    end,
  },
})

local icons = require("config.icons").icons

lsp_zero.set_sign_icons({
  error = icons.diagnostics.Error,
  warn = icons.diagnostics.Warn,
  hint = icons.diagnostics.Hint,
  info = icons.diagnostics.Info,
})

vim.diagnostic.config({
  virtual_text = false,
})
