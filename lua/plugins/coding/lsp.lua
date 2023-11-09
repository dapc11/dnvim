return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = { mason = false },
        lua_ls = {
          settings = {
            workspace = {
              checkThirdParty = "Disable",
            },
            Lua = {
              workspace = {
                checkThirdParty = false,
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
    setup = {
      ruff_lsp = function()
        require("lazyvim.util").lsp.on_attach(function(client, _)
          if client.name == "ruff_lsp" then
            return
          end
        end)
      end,
    },
  },
}
