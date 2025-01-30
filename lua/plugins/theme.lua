return {
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
          bg0 = "#24292e",
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
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        palette = {
          moon = {
            base = "#24292E",
            surface = "#31373F",
            overlay = "#363738",
          },
        },
      })
    end,
  },
}
