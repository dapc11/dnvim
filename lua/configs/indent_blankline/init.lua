local M = {}

function M.config()
  require("indent_blankline").setup({
    active = true,
    on_config_done = nil,
    options = {
      enabled = true,
      buftype_exclude = { "terminal", "nofile" },
      filetype_exclude = {
        "help",
        "startify",
        "dashboard",
        "packer",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      },
      char = "▏",
      show_trailing_blankline_indent = false,
      show_first_indent_level = true,
      use_treesitter = true,
      show_current_context = true,
    },
  })
end

return M
