return {
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
}
