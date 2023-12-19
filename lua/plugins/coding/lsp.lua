return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = false,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.bob", "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        lua_ls = {
          settings = {
            workspace = {
              checkThirdParty = "Disable",
            },
            Lua = {
              workspace = {
                checkThirdParty = "Disable",
              },
              library = {
                vim.fn.expand("$VIMRUNTIME"),
                require("neodev.config").types(),
                "${3rd}/busted/library",
                "${3rd}/luassert/library",
                "${3rd}/luv/library",
              },
              maxPreload = 5000,
              preloadFileSize = 2000,
              diagnostics = {
                globals = {
                  "vim",
                  -- Awesomewm related globals
                  "client",
                  "awesome",
                  "keygrabber",
                  "mouse",
                  "screen",
                  "tag",
                  "mousegrabber",
                  "timer",
                  "restore",
                  "modkey",
                  "root",
                },
              },
            },
          },
        },
      },
    },
  },
}
