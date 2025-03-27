return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".editorconfig" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      format = { enable = true },
      completion = {
        callSnippet = "Replace",
      },
      maxPreload = 5000,
      preloadFileSize = 2000,
      misc = {
        parameters = { "--loglevel=error" },
      },
      hover = { expandAlias = false },
      type = {
        castNumberToInteger = true,
      },
      diagnostics = {
        disable = { "incomplete-signature-doc", "no-unknown" },
        groupSeverity = {
          strong = "Warning",
          strict = "Warning",
        },
        groupFileStatus = {
          ["ambiguity"] = "Opened",
          ["await"] = "Opened",
          ["codestyle"] = "None",
          ["duplicate"] = "Opened",
          ["global"] = "Opened",
          ["luadoc"] = "Opened",
          ["redefined"] = "Opened",
          ["strict"] = "Opened",
          ["strong"] = "Opened",
          ["type-check"] = "Opened",
          ["unbalanced"] = "Opened",
          ["unused"] = "Opened",
        },
        unusedLocalExclude = { "_*" },
        globals = {
          "noop",
          "vim",
          "Snacks",
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
  }
}
