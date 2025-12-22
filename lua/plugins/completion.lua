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
    sources =
    {
      default = {
        "buffer",
        "path",
        "lsp",
      },
      providers = {
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          opts = {
            max_sync_buffer_size = 50000, -- Increased from 20k for instant completion (keeps larger buffers synchronous)
            use_cache = true, -- Cache words per buffer for instant retrieval
            get_bufnrs = function() -- Only include actual file buffers, exclude special/temp buffers
              return vim
                  .iter(vim.api.nvim_list_wins())
                  :map(function(win) return vim.api.nvim_win_get_buf(win) end)
                  :filter(function(buf) return vim.bo[buf].buftype ~= "nofile" end)
                  :totable()
            end,
          },
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
    snippets = {
      expand = function() end,
      active = function() return false end,
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          columns = { { "kind_icon", "label", gap = 1 }, { "source_id" } },
          components = {
            source_id = {
              text = function(ctx) return ctx.source_id end,
              highlight = "Comment",
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
