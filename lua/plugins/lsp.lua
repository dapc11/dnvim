local lazylsp = { "BufReadPre", "BufNewFile" }

local function extend(...)
  local result = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

return {
  { "mfussenegger/nvim-jdtls", ft = "java" },
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "super-tab" },
      appearance = {
        use_nvim_cmp_as_default = true,
      },
      completion = {
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", gap = 1, "kind" } },
          },
        },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    lazy = true,
    events = lazylsp,
    branch = "v3.x",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        dependencies = {
          { "williamboman/mason.nvim", events = lazylsp },
          { "williamboman/mason-lspconfig.nvim", events = lazylsp },
          { "saghen/blink.cmp", events = lazylsp },
        },
        events = lazylsp,
        config = function()
          local capabilities = require("blink.cmp").get_lsp_capabilities()
          local lsp_zero = require("lsp-zero")

          lsp_zero.on_attach(function()
            require("util").lsp_keymaps()
          end)

          local lsp = require("lspconfig")

          require("mason").setup({})

          require("mason-lspconfig").setup({
            ensure_installed = { "jdtls", "helm_ls", "gopls", "lua_ls", "zk@v0.13.0" }, -- zk 0.13.0 due to depenency of glibc version > 2.31.0
            automatic_installation = false,
            handlers = {
              jdtls = noop,
              pyright = function()
                lsp.pyright.setup({
                  capabilities = capabilities,
                  on_init = function(client)
                    client.server_capabilities.semanticTokensProvider = nil
                  end,
                })
              end,
              gopls = function()
                lsp.gopls.setup(extend(require("plugins.language_servers.gopls"), { capabilities = capabilities }))
              end,
              lua_ls = function()
                require("lazydev").setup({})
                lsp.lua_ls.setup(extend(require("plugins.language_servers.lua_ls"), { capabilities = capabilities }))
              end,
              dockerls = function()
                lsp.dockerls.setup(
                  extend(require("plugins.language_servers.dockerls"), { capabilities = capabilities })
                )
              end,
              helm_ls = function()
                lsp.helm_ls.setup(extend(require("plugins.language_servers.helm_ls"), { capabilities = capabilities }))
              end,
              yamlls = function()
                lsp.yamlls.setup({ capabilities = capabilities })
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

          lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.highlight_symbol(client, bufnr)
          end)

          lsp_zero.set_server_config({
            on_init = function(client)
              client.server_capabilities.semanticTokensProvider = nil
            end,
          })

          vim.diagnostic.config({
            virtual_text = true,
            underline = false,
          })
        end,
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "lazy.nvim",
      },
    },
  },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      require("nvim-goc").setup(opts)
    end,
  },
}
