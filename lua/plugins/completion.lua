return {
  "saghen/blink.cmp",
  event = lazyfile,
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "1.0.0",
  opts = {
    keymap = { preset = "default" },
    fuzzy = { implementation = "rust" },
    completion = {
      menu = {
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", gap = 1, "kind" },
          },
        },
      },
    },
    sources = {
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          enabled = true,         -- Whether or not to enable the provider
          async = false,          -- Whether we should wait for the provider to return before showing the completions
          timeout_ms = 2000,      -- How long to wait for the provider to return before showing completions and treating it as asynchronous
          min_keyword_length = 2, -- Minimum number of characters in the keyword to trigger the provider
        },
      },
    },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })
  end
}
