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
