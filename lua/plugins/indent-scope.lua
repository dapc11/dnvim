return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      enabled = true,
      debounce = 200,
      viewport_buffer = {
        min = 30,
        max = 500,
      },
      indent = {
        char = "▎",
        tab_char = nil,
        highlight = "IblIndent",
        smart_indent_cap = true,
        priority = 1,
      },
      whitespace = {
        highlight = "IblWhitespace",
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        char = nil,
        show_start = true,
        show_end = true,
        injected_languages = true,
        highlight = "IblScope",
        priority = 1024,
        include = {
          node_type = {},
        },
        exclude = {
          language = {},
          node_type = {
            ["*"] = {
              "source_file",
              "program",
            },
            lua = {
              "chunk",
            },
            python = {
              "module",
            },
          },
        },
      },
      exclude = {
        filetypes = {
          "fugitive",
          "fugitiveblame",
          "Jaq",
          "qf",
          "fzf",
          "help",
          "man",
          "dap-repl",
          "DressingSelect",
          "OverseerList",
          "Markdown",
          "git",
          "PlenaryTestPopup",
          "lspinfo",
          "notify",
          "spectre_panel",
          "startuptime",
          "tsplayground",
          "neotest-output",
          "checkhealth",
          "neotest-summary",
          "neotest-output-panel",
        },
        buftypes = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      },
    },
  },
}
