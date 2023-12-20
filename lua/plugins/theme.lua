return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
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
}
