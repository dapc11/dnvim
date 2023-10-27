return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
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
  },
}
