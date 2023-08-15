return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
    opts = {
      style = "storm",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.git.change = colors.blue
        colors.git.add = colors.green
        colors.git.delete = colors.red
        colors.hint = colors.blue
        colors.info = colors.blue
        colors.border_highlight = colors.blue
      end,
      on_highlights = function(highlights, colors)
        highlights.WinSeparator = { bg = colors.none, fg = colors.blue }
        highlights.NeoTreeWinSeparator = { bg = colors.bg_sidebar, fg = colors.bg_sidebar }
        highlights.BufferTabpages = { bg = colors.bg_sidebar, fg = colors.none }
        highlights.NeoTreeStatusLineNC = { bg = colors.bg_sidebar, fg = colors.none }
        highlights.NeoTreeStatusLine = { bg = colors.bg_sidebar, fg = colors.bg_sidebar }
        highlights.FloatBorder = { bg = colors.bg, fg = colors.blue }
        highlights.HarpoonBorder = { bg = colors.bg, fg = colors.blue }
        highlights.TelescopeBorder = { bg = colors.bg_sidebar, fg = colors.bg_sidebar }
        highlights.TelescopePromptBorder = { bg = colors.bg_sidebar, fg = colors.bg_sidebar }
        highlights.TelescopeTitle = { fg = colors.blue, bg = colors.bg_sidebar }
        highlights.TelescopePromptNormal = { bg = colors.bg_sidebar }
        highlights.NeogitDiffAdd = { fg = colors.green }
        highlights.NeogitDiffDelete = { fg = colors.red }
        highlights.NeogitDiffAddHighlight = { fg = colors.green, bg = colors.bg_sidebar }
        highlights.NeogitDiffDeleteHighlight = { fg = colors.red, bg = colors.bg_sidebar }
        highlights.NeogitDiffHeaderHighlight = { fg = colors.yellow, bg = colors.bg_sidebar }
        highlights.NeogitDiffContextHighlight = { bg = colors.bg }
        highlights.NeogitHunkHeaderHighlight = { fg = colors.fg, bold = true }
        highlights.NeogitHunkHeader = { fg = colors.blue, bold = true }
        highlights.NormalFloat = { bg = colors.bg_sidebar }
        highlights.Pmenu = { bg = colors.bg_sidebar }
        highlights.NoicePopupmenu = { bg = colors.bg_sidebar }
        highlights.NoicePopup = { bg = colors.bg_sidebar }
        highlights.TabLine = { bg = colors.bg_sidebar }
        highlights.TabLineSel = { fg = colors.blue, bg = colors.bg_sidebar }
        highlights.TabLineFill = { bg = colors.bg_sidebar }
        highlights.BqfPreviewFloat = { bg = colors.bg }
        highlights.NeoTreeDirectoryName = { bold = true }
      end,
    },
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
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local custom_theme = require("lualine.themes.auto")
      local colors = require("tokyonight.colors").setup()

      custom_theme.normal = {
        a = { bg = colors.blue, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.blue },
        c = { bg = colors.bg_sidebar, fg = colors.fg_sidebar },
      }

      custom_theme.insert = {
        a = { bg = colors.green, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.green },
      }

      custom_theme.command = {
        a = { bg = colors.yellow, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.yellow },
      }

      custom_theme.visual = {
        a = { bg = colors.magenta, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.magenta },
      }

      custom_theme.replace = {
        a = { bg = colors.red, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.red },
      }

      custom_theme.terminal = {
        a = { bg = colors.green1, fg = colors.black },
        b = { bg = colors.fg_gutter, fg = colors.green1 },
      }

      custom_theme.inactive = {
        a = { bg = colors.bg_sidebar, fg = colors.blue },
        b = { bg = colors.bg_sidebar, fg = colors.fg_gutter, gui = "bold" },
        c = { bg = colors.bg_sidebar, fg = colors.fg_gutter },
      }

      local neotree = { sections = {}, filetypes = { "neo-tree" } }
      return {
        options = {
          theme = custom_theme,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        extensions = { "trouble", "nvim-dap-ui", "overseer", neotree, "lazy" },
      }
    end,
  },
}
