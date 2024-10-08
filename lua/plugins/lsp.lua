local lazylsp = { "BufReadPre", "BufNewFile" }
return {
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
          { "hrsh7th/cmp-nvim-lsp", events =  { "InsertEnter", "CmdlineEnter" } },
          { "hrsh7th/cmp-nvim-lsp-signature-help", events =  { "InsertEnter", "CmdlineEnter" } },
          { "hrsh7th/cmp-buffer", events =  { "InsertEnter", "CmdlineEnter" } },
          { "hrsh7th/cmp-path", events =  { "InsertEnter", "CmdlineEnter" } },
          { "hrsh7th/nvim-cmp", events =  { "InsertEnter", "CmdlineEnter" } },
        },
        events = lazylsp,
        config = function()
          local cmp = require("cmp")
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          local luasnip = require("luasnip")
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

          require("luasnip.loaders.from_vscode").lazy_load({
            paths = "~/.config/nvim/snippets",
          })

          cmp.setup({
            sources = {
              { name = "nvim_lsp_signature_help" },
              { name = "nvim_lsp" },
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
              ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.locally_jumpable(1) then
                      luasnip.jump(1)
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.locally_jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" }),
              ["<C-n>"] = cmp.mapping.select_next_item(),
              ["<C-p>"] = cmp.mapping.select_prev_item(),
              ["<C-j>"] = cmp.mapping.select_next_item(),
              ["<C-k>"] = cmp.mapping.select_prev_item(),
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
              completion = { scrollbar = false },
              documentation = { scrollbar = false },
            },
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
          })
          local lsp_zero = require("lsp-zero")

          lsp_zero.on_attach(function()
            require("util").lsp_keymaps()
          end)

          local lsp = require("lspconfig")

          require("mason").setup({})

          require("mason-lspconfig").setup({
            ensure_installed = {"helm_ls", "gopls", "lua_ls", "pyright", "dockerls", "zk@v0.13.0" }, -- zk 0.13.0 due to depenency of glibc version > 2.31.0
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
              helm_ls = function ()
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
