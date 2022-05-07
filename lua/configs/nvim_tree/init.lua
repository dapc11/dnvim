local M = {}
function M.config()
  vim.g.nvim_tree_highlight_opened_files = 1
  vim.g.nvim_tree_root_folder_modifier = table.concat({ ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" })

  vim.g.nvim_tree_respect_buf_cwd = 1
  vim.g.nvim_tree_show_icons = {
    git = 1,
    folder_arrows = 0,
    folders = 1,
    files = 0,
  }

  require("nvim-tree").setup({
    auto_reload_on_write = true,
    disable_netrw = false,
    hijack_netrw = false,
    ignore_ft_on_setup = { "dashboard" },
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = { "**/.git" },
    },
    renderer = {
      indent_markers = {
        enable = false,
      },
    },
    git = {
      enable = true,
      ignore = false,
      timeout = 500,
    },
    filters = {
      dotfiles = false,
      custom = { ".git" },
    },
    diagnostics = {
      enable = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "",
      },
    },
    view = {
      width = 30,
      side = "left",
      mappings = {
        custom_only = false,
        list = {
          { key = "<C-t>", action = "" },
          { key = "P", action = "parent_node" },
          { key = "y", action = "copy_name" },
          { key = "Y", action = "copy_path" },
          { key = "gy", action = "copy_absolute_path" },
          { key = "W", action = "collapse_all" },
        },
      },
    },
  })
end

return M
