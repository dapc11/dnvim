return {
  "saghen/blink.cmp",
  event = lazyfile,
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "super-tab",
    },
    fuzzy = {
      implementation = "rust",
    },
    sources = {
      providers = {
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          enabled = true,
          min_keyword_length = 1,
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          enabled = true,
          min_keyword_length = 1,
        },
        snippets = {
          name = "Snippets",
          module = "blink.cmp.sources.snippets",
          enabled = true,
          min_keyword_length = 1,
        },
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          enabled = true,
          async = false,
          timeout_ms = 2000, -- LSP completion timeout
          min_keyword_length = 1,
        },
      },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        auto_show = true,
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", gap = 1, "kind" },
          },
        },
      },
    },
  },
  config = function(_, opts)
    local cmp = require("blink.cmp")
    cmp.setup(opts)
    vim.lsp.config("*", {
      capabilities = cmp.get_lsp_capabilities(),
    })
  end,
}

