local openfile = require("nvim-tree.actions.node.open-file")
local nt_api = require("nvim-tree.api")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")
local M = {}

local view_selection = function(prompt_bufnr, _)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local filename = selection.filename
    if filename == nil then
      filename = selection[1]
    end
    openfile.fn("preview", filename)
    nt_api.tree.close()
  end)
  return true
end

function M.launch_live_grep(opts)
  opts = {
    hidden = true,
    previewer = false,
    layout_config = {
      cursor = {
        height = 0.40,
        width = 0.40,
      },
    },
  }
  return M.launch_telescope("live_grep", opts)
end

function M.launch_find_files(opts)
  opts = {
    hidden = true,
    initial_mode = "normal",
    layout_config = {
      height = 0.25,
      width = 0.40,
    },
  }
  return M.launch_telescope("find_files", opts)
end

function M.launch_telescope(picker, opts)
  local telescope_status_ok, _ = pcall(require, "telescope")
  if not telescope_status_ok then
    return
  end
  local lib_status_ok, lib = pcall(require, "nvim-tree.lib")
  if not lib_status_ok then
    return
  end
  local node = lib.get_node_at_cursor()
  local is_folder = node.fs_stat and node.fs_stat.type == "directory" or false
  local basedir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  if node.name == ".." and TreeExplorer ~= nil then
    basedir = TreeExplorer.cwd
  end

  opts.cwd = basedir
  opts.search_dirs = { basedir }
  opts.attach_mappings = view_selection
  return require("telescope.builtin")[picker](themes.get_cursor(opts))
end

return M
