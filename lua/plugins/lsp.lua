local lazylsp = { "BufReadPre", "BufNewFile" }
return {
  {
    "stevearc/conform.nvim",
    ft = { "lua", "python", "go" },
    opts = {
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        go = { "goimports", "gofmt" },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    events = lazylsp,
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = {
        "stylua",
        "black",
        "goimports",
      },
    },
  },
  { "mfussenegger/nvim-jdtls", ft = "java" },
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
          { "L3MON4D3/LuaSnip", events = lazylsp },
          { "saadparwaiz1/cmp_luasnip", events = lazylsp },
          { "hrsh7th/cmp-nvim-lsp", events = lazylsp },
          { "hrsh7th/cmp-nvim-lua", events = lazylsp },
          { "hrsh7th/cmp-buffer", events = lazylsp },
          { "hrsh7th/cmp-path", events = lazylsp },
          { "hrsh7th/nvim-cmp", events = lazylsp },
        },
        events = lazylsp,
        config = function()
          local cmp = require("cmp")
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          local luasnip = require("luasnip")
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

          require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
          cmp.setup({
            sources = {
              { name = "nvim_lsp" },
              { name = "nvim_lua" },
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
            },

            mapping = cmp.mapping.preset.insert({
              ["<CR>"] = cmp.mapping.confirm({ select = false }),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-l>"] = cmp.mapping(function()
                if luasnip.expand_or_locally_jumpable() then
                  luasnip.expand_or_jump()
                end
              end, { "i", "s" }),
              ["<C-h>"] = cmp.mapping(function()
                if luasnip.locally_jumpable(-1) then
                  luasnip.jump(-1)
                end
              end, { "i", "s" }),
              ["<C-n>"] = cmp.mapping.select_next_item(),
              ["<C-p>"] = cmp.mapping.select_prev_item(),
              ["<C-y>"] = cmp.mapping.confirm({ select = true }),
              ["<C-u>"] = cmp.mapping.scroll_docs(-4),
              ["<C-d>"] = cmp.mapping.scroll_docs(4),
              ["<C-e>"] = cmp.mapping.abort(),
            }),
            formatting = {
              format = function(entry, vim_item)
                vim_item.dup = ({
                  buffer = 0,
                  nvim_lsp = 1,
                  luasnip = 1,
                })[entry.source.name] or 0
                return vim_item
              end,
            },
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
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
              lsp_zero.default_setup,
              dockerls = function()
                require("lspconfig").dockerls.setup({
                  on_init = function(client)
                    client.server_capabilities.semanticTokensProvider = nil
                  end,
                })
              end,
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
    "folke/neodev.nvim",
    ft = "lua",
    config = false,
  },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      local goc = require("nvim-goc")
      goc.setup(opts)
    end,
  },
}
