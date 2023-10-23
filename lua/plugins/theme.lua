return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
  {
    "navarasu/onedark.nvim",
    enabled = false,
    config = function()
      local bg = "#24292e"
      local sidebar = "#282c34"
      local fg = "#b6bdca"
      require("onedark").setup({
        style = "dark",
        colors = { bg0 = bg },
        highlights = {
          NormalFloat = { bg = sidebar },
          FloatBorder = { bg = sidebar, fg = sidebar },
          FloatTitle = { bg = sidebar, fmt = "bold" },
          TelescopeBorder = { bg = sidebar, fg = sidebar },
          TelescopePreviewBorder = { bg = sidebar, fg = sidebar },
          TelescopeResultsBorder = { bg = sidebar, fg = sidebar },
          TelescopePromptBorder = { bg = sidebar, fg = sidebar },
          TelescopeNormal = { bg = sidebar },
          TelescopeTitle = { fg = fg, bg = sidebar, fmt = "bold" },
          TelescopePromptNormal = { fg = fg, bg = sidebar },

          FzfLuaBufNr = { bg = sidebar, fg = fg },
          FzfLuaTitle = { bg = sidebar, fg = fg, fmt = "bold" },
          FzfLuaBorder = { bg = sidebar, fg = sidebar },
          FzfLuaCursor = { bg = sidebar, fg = fg },
          FzfLuaNormal = { bg = sidebar, fg = fg },
          FzfLuaBufName = { bg = sidebar, fg = fg },
          FzfLuaTabTitle = { bg = sidebar, fg = sidebar, fmt = "bold" },
          FzfLuaBufLineNr = { bg = sidebar, fg = fg },
          FzfLuaTabMarker = { bg = sidebar },
          FzfLuaBufFlagAlt = { bg = sidebar },
          FzfLuaBufFlagCur = { bg = sidebar },
          -- FzfLuaCursorLine = { bg = sidebar },
          FzfLuaHeaderBind = { bg = sidebar },
          FzfLuaHeaderText = { bg = sidebar, fg = fg, fmt = "bold" },
          FzfLuaHelpBorder = { bg = sidebar, fg = sidebar },
          FzfLuaHelpNormal = { bg = sidebar },
          FzfLuaCursorLineNr = { bg = sidebar, fg = sidebar },
          FzfLuaPreviewTitle = { bg = sidebar, fg = fg, fmt = "bold" },
          FzfLuaPreviewBorder = { bg = sidebar, fg = fg },
          FzfLuaPreviewNormal = { bg = sidebar },
        },
      })
      require("onedark").load()
    end,
    priority = 1000,
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
  --           FzfLuaCursorLine = { bg = colors.base },
  --           FzfLuaHelpNormal = { fg = colors.red },
  --           FzfLuaHeaderText = { fg = colors.red },
  --           FzfLuaBufLineNr = { fg = colors.blue },
  --           FzfLuaBufFlagCur = { fg = colors.blue },
  --           FzfLuaBufFlagAlt = { fg = colors.sky },
  --           FzfLuaTabMarker = { bg = colors.base },
  --           FzfLuaBorder = { fg = colors.blue },
  --         }
  --       end,
  --     })
  --     vim.cmd([[colorscheme catppuccin-frappe]])
  --   end,
  -- },
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
