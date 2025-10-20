return {
  "saghen/blink.cmp",
  event = lazyfile,
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "mikavilpas/blink-ripgrep.nvim",
      version = "*",
    },

  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "super-tab",
    },
    fuzzy = {
      implementation = "rust",
    },
    sources =
    {
      default = {
        "buffer",
        "ripgrep",
        "path",
        "lsp",
      },
      providers = {
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          opts = {},
        },
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          enabled = true,
          async = false,
          timeout_ms = 2000, -- LSP completion timeout
          min_keyword_length = 1,
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          enabled = true,
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
          padding = { 0, 1 }, -- padding only on right side
          components = {
            kind_icon = {
              text = function(ctx) return " " .. ctx.kind_icon .. ctx.icon_gap .. " " end,
            },
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
