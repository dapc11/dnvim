local M = {}

function M.config()
  local components = require("configs.lualine.components")
  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "onedark",
      section_separators = {},
      component_separators = {},
      disabled_filetypes = { "NvimTree" },
      always_divide_middle = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = {
        components.mode,
      },
      lualine_b = {
        components.branch,
        components.filename,
      },
      lualine_c = {
        components.diff,
        components.python_env,
      },
      lualine_x = {
        components.diagnostics,
        components.treesitter,
        components.lsp,
        components.filetype,
      },
      lualine_y = {},
      lualine_z = {
        components.scrollbar,
      },
    },
    inactive_sections = {
      lualine_a = {
        "filename",
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = { "toggleterm", "fzf", "fugitive", "NvimTree" },
  })
end

return M
