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
  },
}
