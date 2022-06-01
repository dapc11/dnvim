local M = {}

function M.config()
  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "onedark",
      section_separators = "",
      component_separators = "",
      disabled_filetypes = { "neo-tree" },
      always_divide_middle = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } } },
      lualine_c = { { "filename", file_status = true, path = 3, shorting_target = 40 } },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {
      lualine_a = { "buffers" },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "toggleterm", "fzf", "fugitive", "neo-tree" },
  })
end

return M
