return {
  "saghen/blink.cmp",
  event = lazyfile,
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "1.0.0",
  opts = {
    keymap = { preset = "none" }, -- We'll handle keymaps with super tab
    fuzzy = { implementation = "rust" },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        auto_show = false, -- We'll control when to show via super tab
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", gap = 1, "kind" },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
    },
    sources = {
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          enabled = true,
          async = false,
          timeout_ms = 2000,
          min_keyword_length = 1, -- Reduced for better super tab experience
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
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          enabled = true,
          min_keyword_length = 2,
        },
      },
    },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })
  end,
}
