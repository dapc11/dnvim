return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".editorconfig" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      format = {
        enable = true,
        defaultConfig = {
          align_array_table = "false",
          align_call_args = "false",
          align_chain_expr = "none",
          align_continuous_assign_statement = "false",
          align_continuous_inline_comment = "false",
          align_continuous_line_space = "2",
          align_continuous_rect_table_field = "false",
          align_continuous_similar_call_args = "false",
          align_function_params = "false",
          align_if_branch = "false",
          call_arg_parentheses = "keep",
          indent_size = "2",
          indent_style = "space",
          insert_final_newline = "true",
          max_line_length = "120",
          quote_style = "double",
          trailing_table_separator = "smart",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          unpack(vim.api.nvim_get_runtime_file("", true)),
        },
      },
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
          "MiniStarter",
          "Snacks",
          "noop",
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

