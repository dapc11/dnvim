return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
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
    lazy = false,
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
