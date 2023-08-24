return {
  {
    "rcarriga/nvim-notify",
    opts = {
      max_height = 1,
      render = "compact",
      stages = "static",
      timeout = 1000,
    },
    keys = function()
      return {
        {
          "<C-x>",
          function()
            require("notify").dismiss({ silent = true, pending = true })
          end,
          desc = "Dismiss all Notifications",
        },
      }
    end,
  },
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     lsp = {
  --       override = {
  --         ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --         ["vim.lsp.util.stylize_markdown"] = true,
  --         ["cmp.entry.get_documentation"] = true,
  --       },
  --     },
  --     cmdline = {
  --       enabled = true, -- enables the Noice cmdline UI
  --       view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
  --       opts = {}, -- global options for the cmdline. See section on views
  --       ---@type table<string, CmdlineFormat>
  --       format = {
  --         -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
  --         -- view: (default is cmdline view)
  --         -- opts: any options passed to the view
  --         -- icon_hl_group: optional hl_group for the icon
  --         -- title: set to anything or empty string to hide
  --         cmdline = { pattern = "^:", icon = "", lang = "vim" },
  --         search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
  --         search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
  --         filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
  --         lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
  --         help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
  --         input = {}, -- Used by input()
  --         -- lua = false, -- to disable a format, set to `false`
  --       },
  --     },
  --     presets = {
  --       bottom_search = true, -- use a classic bottom cmdline for search
  --       command_palette = true, -- position the cmdline and popupmenu together
  --       long_message_to_split = true, -- long messages will be sent to a split
  --       inc_rename = false, -- enables an input dialog for inc-rename.nvim
  --       lsp_doc_border = false, -- add a border to hover docs and signature help
  --     },
  --   },
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  --   keys = {
  --     {
  --       "<S-Enter>",
  --       function()
  --         require("noice").redirect(vim.fn.getcmdline())
  --       end,
  --       mode = "c",
  --       desc = "Redirect Cmdline",
  --     },
  --     {
  --       "<leader>snl",
  --       function()
  --         require("noice").cmd("last")
  --       end,
  --       desc = "Noice Last Message",
  --     },
  --     {
  --       "<leader>snh",
  --       function()
  --         require("noice").cmd("history")
  --       end,
  --       desc = "Noice History",
  --     },
  --     {
  --       "<leader>sna",
  --       function()
  --         require("noice").cmd("all")
  --       end,
  --       desc = "Noice All",
  --     },
  --     {
  --       "<leader>snd",
  --       function()
  --         require("noice").cmd("dismiss")
  --       end,
  --       desc = "Dismiss All",
  --     },
  --   },
  -- },
}
