return {
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  settings = {
    workspace = {
      library = {
        [vim.fn.expand "$VIMRUNTIME/lua"] = true,
        [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
      },
      checkThirdParty = "Disable",
    },
    Lua = {
      format = { enable = false },
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
  },
}
