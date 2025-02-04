local lazylsp = { "BufReadPre", "BufNewFile" }
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
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
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
        },
        events = lazylsp,
        config = function()
          local lsp_zero = require("lsp-zero")

          lsp_zero.on_attach(function()
            require("util").lsp_keymaps()
          end)

          local lsp = require("lspconfig")

          require("mason").setup({})

          require("mason-lspconfig").setup({
            ensure_installed = { "helm_ls", "gopls", "lua_ls", "pyright", "dockerls", "zk@v0.13.0" }, -- zk 0.13.0 due to depenency of glibc version > 2.31.0
            handlers = {
              pyright = function()
                lsp.pyright.setup({
                  on_init = function(client)
                    client.server_capabilities.semanticTokensProvider = nil
                  end,
                })
              end,
              gopls = function()
                lsp.gopls.setup(require("plugins.language_servers.gopls"))
              end,
              lua_ls = function()
                require("lazydev").setup({})
                lsp.lua_ls.setup(require("plugins.language_servers.lua_ls"))
              end,
              dockerls = function()
                lsp.dockerls.setup(require("plugins.language_servers.dockerls"))
              end,
              helm_ls = function()
                lsp.helm_ls.setup(require("plugins.language_servers.helm_ls"))
              end,
              yamlls = function()
                lsp.yamlls.setup({})
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

          lsp_zero.set_server_config({
            on_init = function(client)
              client.server_capabilities.semanticTokensProvider = nil
            end,
          })

          vim.diagnostic.config({
            virtual_text = false,
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
  { "Bilal2453/luvit-meta", lazy = true },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      require("nvim-goc").setup(opts)
    end,
  },
}
