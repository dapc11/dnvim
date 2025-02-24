local function extend(...)
  local result = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

local filtered_packages = {}

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
          auto_show = function(ctx)
            return ctx.mode ~= "cmdline"
          end,
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", gap = 1, "kind" },
            },
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
    events = _G.lazyfile,
    branch = "v3.x",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        dependencies = {
          { "williamboman/mason.nvim", events = _G.lazyfile },
          { "williamboman/mason-lspconfig.nvim", events = _G.lazyfile },
          { "saghen/blink.cmp", events = _G.lazyfile },
        },
        events = _G.lazyfile,
        config = function()
          local capabilities = require("blink.cmp").get_lsp_capabilities()
          local lsp_zero = require("lsp-zero")

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
                })
              end,
              gopls = function()
                lsp.gopls.setup(
                  extend(require("plugins.language_servers.gopls"), { capabilities = capabilities })
                )
              end,
              lua_ls = function()
                lsp.lua_ls.setup({
                  settings = require("plugins.language_servers.lua_ls"),
                  capabilities = capabilities,
                })
              end,
              dockerls = function()
                lsp.dockerls.setup(
                  extend(
                    require("plugins.language_servers.dockerls"),
                    { capabilities = capabilities }
                  )
                )
              end,
              helm_ls = function()
                lsp.helm_ls.setup(
                  extend(
                    require("plugins.language_servers.helm_ls"),
                    { capabilities = capabilities }
                  )
                )
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

          local keymaps = require("util").lsp_keymaps
          lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.highlight_symbol(client, bufnr)
            keymaps()
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
    ft = "lua",
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
  {
    "fredrikaverpil/godoc.nvim",
    version = "2.x",
    dependencies = {
      { "folke/snacks.nvim" },
      {
        "nvim-treesitter/nvim-treesitter",
        opts = {
          ensure_installed = { "go", "python" },
        },
      },
    },
    opts = {
      adapters = {
        {
          command = "PyDoc",
          get_items = function()
            if #filtered_packages ~= 0 then
              return filtered_packages
            end

            local function split(input_str)
              local result = {}
              for word in input_str:gmatch("%S+") do
                table.insert(result, word)
              end
              return result
            end

            local std_packages = vim.fn.systemlist("python3 -c 'help(\"modules\")'")
            for index, value in ipairs(std_packages) do
              if index > 11 and index < #std_packages - 2 then
                for _, va in ipairs(split(value)) do
                  table.insert(filtered_packages, va)
                end
              end
            end
            table.sort(filtered_packages)
            return filtered_packages
          end,
          get_content = function(choice)
            return vim.fn.systemlist("python3 -m pydoc " .. choice)
          end,
          get_syntax_info = function()
            return {
              filetype = "pydoc",
              language = "python",
            }
          end,
        },
      },
    },
  },
}
