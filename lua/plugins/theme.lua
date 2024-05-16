return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
      transparent = false, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
      },
      sidebars = require("util.common").ignored_filetypes,
    },
  },
  {
    "navarasu/onedark.nvim",
    enabled = true,
    priority = 1000,
    config = function()
      local winsep = "$fg"
      require("onedark").setup({
        style = "dark",
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        colors = {
          fg = "#b6bdca",
        },
        highlights = {
          NormalFloat = { bg = "$bg0" },
          FloatBorder = { bg = "$bg0", fg = winsep },
          WinSeparator = { bg = "bg0", fg = winsep },
          FloatTitle = { bg = "$bg0", fmt = "bold" },
          TelescopeBorder = { bg = "$bg0", fg = winsep },
          TelescopePreviewBorder = { bg = "$bg0", fg = winsep },
          TelescopeResultsBorder = { bg = "$bg0", fg = winsep },
          TelescopePromptBorder = { bg = "$bg0", fg = winsep },
          TelescopeNormal = { bg = "$bg0" },
          TelescopeTitle = { fg = "$fg", bg = "$bg0", fmt = "bold" },
          TelescopePromptNormal = { fg = "$fg", bg = "$bg0" },
          Include = { fg = "$orange" },
          Statement = { fg = "$orange" },
          Special = { fg = "$orange" },
          Conditional = { fg = "$orange" },
          Exception = { fg = "$orange" },
          Define = { fg = "$blue" },
          Operator = { fg = "$orange" },
          Repeat = { fg = "$orange" },
          DiffAdd = { fg = "$green", bg = "$bg0" },
          DiffDelete = { fg = "$red", bg = "$bg0" },
          DiffChange = { fg = "$blue", bg = "$bg0" },

          ["@field"] = { fg = "$fg", fmt = "none" },
          ["@function"] = { fg = "$blue", fmt = "none" },
          ["@method"] = { fg = "$blue", fmt = "none" },
          ["@parameter"] = { fg = "$fg", fmt = "bold" },
          ["@parameter.bash"] = { fg = "$fg", fmt = "none" },
          ["@string.escape"] = { fg = "$dark_cyan", fmt = "none" },
          ["@keyword"] = { fg = "$orange", fmt = "none" },
          ["@keyword.function"] = { fg = "$orange", fmt = "none" },
          ["@keyword.repeat"] = { fg = "$orange", fmt = "none" },
          ["@keyword.import"] = { fg = "$orange", fmt = "none" },
          ["@keyword.directive"] = { fg = "$orange", fmt = "none" },
          ["@keyword.operator"] = { fg = "$orange", fmt = "none" },
          ["@keyword.conditional"] = { fg = "$orange", fmt = "none" },
          ["@keyword.exception"] = { fg = "$orange", fmt = "none" },
          ["@constructor"] = { fg = "$blue", fmt = "none" },
          ["@attribute"] = { fg = "$fg", fmt = "none" },
          ["@variable"] = { fg = "$fg", fmt = "none" },
          ["@variable.builtin"] = { fg = "$fg", fmt = "none" },
          ["@variable.member"] = { fg = "$fg", fmt = "none" },
          ["@variable.parameter"] = { fg = "$fg", fmt = "none" },
          ["@punctuation.special"] = { fg = "$fg", fmt = "none" },
          ["@property.yaml"] = { fg = "$fg", fmt = "none" },
        },
      })
      require("onedark").load()
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
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    opts = {
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
        local u = colors.theme.ui
        local p = colors.palette

        return {
          StatusLine = { bg = u.bg_p1 },
          StatusLineNC = { bg = u.bg_p1 },
          Error = { fg = p.autumnRed },
          DiagnosticError = { fg = p.autumnRed },
          DiagnosticSignError = { fg = p.autumnRed },
          ErrorMsg = { fg = p.autumnRed, bg = p.sumilnk0 },
          Pmenu = { fg = u.shade0, bg = u.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
          PmenuSel = { fg = "NONE", bg = u.bg_p2 },
          PmenuSbar = { bg = u.bg_m1 },
          PmenuThumb = { bg = u.bg_p2 },
          WhichKeyFloat = { bg = p.sumiInk4 },
          FloatBorder = { bg = u.bg, fg = u.fg },
          WinSeparator = { bg = u.bg, fg = u.fg, bold = true },

          MiniStarterCurrent = { fg = u.fg, bold = true },
          MiniStarterFooter = { fg = p.dragonRed, italic = true },
          MiniStarterHeader = { fg = p.carpYellow },
          MiniStarterInactive = { fg = p.katanaGray, italic = true },
          MiniStarterItem = { fg = u.fg_dim, bg = u.bg },
          MiniStarterItemBullet = { fg = p.katanaGray },
          MiniStarterItemPrefix = { fg = p.surimiOrange, bold = true },
          MiniStarterSection = { fg = p.crystalBlue, bold = true },
          MiniStarterQuery = { fg = p.springBlue },

          MiniStatuslineDevinfo = { fg = u.fg, bg = u.bg_p2 },
          MiniStatuslineFileinfo = { fg = u.fg, bg = u.bg_p2 },
          MiniStatuslineFilename = { fg = p.katanaGray, bg = u.bg_p1 },
          MiniStatuslineInactive = { fg = p.katanaGray, bg = u.bg },
          MiniStatuslineModeCommand = { fg = u.bg, bg = p.autumnYellow, bold = true },
          MiniStatuslineModeInsert = { fg = u.bg, bg = p.lotusBlue3, bold = true },
          MiniStatuslineModeNormal = { fg = u.bg, bg = p.lotusGreen2, bold = true },
          MiniStatuslineModeOther = { fg = u.bg, bg = p.lotusCyan, bold = true },
          MiniStatuslineModeReplace = { fg = u.bg, bg = p.lotusRed2, bold = true },
          MiniStatuslineModeVisual = { fg = u.bg, bg = p.lotusViolet2, bold = true },

          ["Constant"] = { fg = p.carpYellow },
          ["Number"] = { fg = p.lotusBlue3 },
          ["Float"] = { fg = p.lotusBlue3 },
          ["Boolean"] = { fg = p.surimiOrange },
          ["Character"] = { fg = p.surimiOrange },
          ["String"] = { fg = p.springGreen },
          ["Identifier"] = { fg = u.fg },
          ["Function"] = { fg = u.fg },
          ["Statement"] = { fg = p.surimiOrange },
          ["Conditional"] = { fg = p.surimiOrange },
          ["Repeat"] = { fg = p.surimiOrange },
          ["Label"] = { fg = p.surimiOrange },
          ["Operator"] = { fg = u.fg },
          ["Keyword"] = { fg = p.surimiOrange },
          ["Exception"] = { fg = p.lotusRed },
          ["PreProc"] = { fg = p.oniViolet },
          ["Include"] = { fg = p.oniViolet },
          ["Define"] = { fg = p.oniViolet },
          ["Macro"] = { fg = p.oniViolet },
          ["PreCondit"] = { fg = p.oniViolet },
          ["Type"] = { fg = u.fg },
          ["@keyword.return"] = { fg = p.oniViolet },
          ["StorageClass"] = { fg = p.oniViolet },
          ["Structure"] = { fg = p.oniViolet },
          ["Typedef"] = { fg = p.oniViolet },
          ["Special"] = { fg = p.surimiOrange },
          ["SpecialChar"] = { fg = p.surimiOrange },
          ["Tag"] = { fg = p.lotusYellow },
          ["Delimiter"] = { fg = p.surimiOrange },
          ["SpecialComment"] = { fg = p.surimiOrange },
          ["Debug"] = { fg = p.surimiOrange },
          ["DiffAdded"] = { fg = p.springGreen },
          ["fugitiveStagedSection"] = { fg = p.crystalBlue },
          ["@markup.heading.1.markdown"] = { fg = p.lotusBlue5 },
          ["@markup.heading.2.markdown"] = { fg = p.lotusBlue4 },
          ["@markup.heading.3.markdown"] = { fg = p.lotusBlue3 },
          ["@markup.heading.4.markdown"] = { fg = p.lotusBlue2 },
          ["@markup.list.markdown"] = { fg = p.surimiOrange },
          ["markdownBold"] = { fg = u.fg_dim, bold = true },
          ["markdownItalic"] = { fg = u.fg_dim, italic = true },
          ["markdownBlockquote"] = { fg = p.oniViolet },
        }
      end,
    },
  },
}
