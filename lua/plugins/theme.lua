return {
  {
    "kvrohit/rasmus.nvim",
    priority = 1000,
    lazy = false,
    enabled = false,
    init = function()
      -- Configure the appearance
      vim.g.rasmus_italic_functions = true
      vim.g.rasmus_bold_functions = true

      -- Set the colorscheme variant to monochrome
      vim.g.rasmus_variant = "dark"

      -- Load the colorscheme
      vim.cmd([[colorscheme rasmus]])
    end,
  },
  {
    "navarasu/onedark.nvim",
    enabled = true,
    priority = 1000,
    config = function()
      local bg = "#24292e"
      local sidebar = "#282c34"
      local fg = "#b6bdca"
      local winsep = "#848b98"
      require("onedark").setup({
        style = "dark",
        colors = { bg0 = bg },
        highlights = {
          NormalFloat = { bg = sidebar },
          FloatBorder = { bg = sidebar, fg = sidebar },
          WinSeparator = { bg = bg, fg = winsep },
          NeoTreeWinSeparator = { bg = bg, fg = winsep },
          FloatTitle = { bg = sidebar, fmt = "bold" },
          TelescopeBorder = { bg = sidebar, fg = sidebar },
          TelescopePreviewBorder = { bg = sidebar, fg = sidebar },
          TelescopeResultsBorder = { bg = sidebar, fg = sidebar },
          TelescopePromptBorder = { bg = sidebar, fg = sidebar },
          TelescopeNormal = { bg = sidebar },
          TelescopeTitle = { fg = fg, bg = sidebar, fmt = "bold" },
          TelescopePromptNormal = { fg = fg, bg = sidebar },
        },
      })
      require("onedark").load()
    end,
  },
  -- {
  --   "catppuccin/nvim",
  --   enabled = false,
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       custom_highlights = function(colors)
  --         return {
  --           NeoTreeNormal = { fg = colors.text, bg = colors.mantle },
  --           NeoTreeNormalNC = { fg = colors.text, bg = colors.mantle },
  --           WinSeparator = { bg = colors.mantle, fg = colors.mantle },
  --           NormalFloat = { bg = colors.base },
  --         }
  --       end,
  --     })
  --     vim.cmd([[colorscheme catppuccin-frappe]])
  --   end,
  -- },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    config = function(_, opts)
      require("kanagawa").setup(vim.tbl_extend("force", opts, {
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            StatusLine = { bg = colors.palette.winterBlue },
            StatusLineNC = { bg = colors.palette.winterBlue },
            Error = { fg = colors.palette.autumnRed },
            DiagnosticError = { fg = colors.palette.autumnRed },
            DiagnosticSignError = { fg = colors.palette.autumnRed },
            ErrorMsg = { fg = colors.palette.autumnRed, bg = colors.palette.sumilnk0 },
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
            PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
          }
        end,
      }))
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      filetypes = {
        "*",
        "lua",
        "!lazy",
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        mode = "virtualtext",
        virtualtext = "■■■■■",
      },
    },
  },
}
