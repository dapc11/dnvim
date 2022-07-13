local M = {}

function M.config()
  local status_ok, telescope = pcall(require, "telescope")
  if not status_ok then
    return
  end

  local actions = require("telescope.actions")
  local action_layout = require("telescope.actions.layout")
  local putils = require("telescope.previewers.utils")

  telescope.setup({
    pickers = {
      jumplist = {
        theme = "ivy",
      },
      projects = {
        theme = "ivy",
      },
      current_buffer_fuzzy_find = {
        theme = "ivy",
      },
      live_grep = {
        theme = "ivy",
      },
      grep_string = {
        theme = "ivy",
      },
      oldfiles = {
        theme = "ivy",
      },
      git_branches = {
        theme = "ivy",
      },
      git_commits = {
        theme = "ivy",
      },
      git_status = {
        theme = "ivy",
      },
      git_files = {
        theme = "ivy",
      },
      find_files = {
        theme = "ivy",
      },
      buffers = {
        theme = "ivy",
        mappings = {
          n = {
            ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
          },
          i = {
            ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
          },
        },
      },
    },
    defaults = {
      prompt_prefix = " ",
      selection_caret = "❯ ",
      file_ignore_patterns = { "node_modules", ".git", ".jar", ".tar.gz", ".zip", ".png", ".jpeg", ".cache" },
      vimgrep_arguments = {
        "rg",
        "--no-heading",
        "--color=never",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--trim",
      },
      mappings = {
        n = {
          ["<C-p>"] = action_layout.toggle_preview,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["<s-tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<tab>"] = actions.toggle_selection + actions.move_selection_previous,
          ["<C-c>"] = actions.close,
        },
        i = {
          ["<C-p>"] = action_layout.toggle_preview,
          ["<C-c>"] = actions.close,
          ["<esc>"] = actions.close,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["<s-tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<tab>"] = actions.toggle_selection + actions.move_selection_previous,
          ["<CR>"] = actions.select_default,
          ["<C-h>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-o>"] = actions.select_tab,
        },
      },
      preview = {
        filetype_hook = function(filepath, bufnr, opts)
          -- you could analogously check opts.ft for filetypes
          local excluded = vim.tbl_filter(function(ending)
            return filepath:match(ending)
          end, {
            ".*%.jar",
            ".*%.tar.gz",
          })
          if not vim.tbl_isempty(excluded) then
            putils.set_preview_message(
              bufnr,
              opts.winid,
              string.format("I don't like %s files!", excluded[1]:sub(5, -1))
            )
            return false
          end
          return true
        end,
        filesize_hook = function(filepath, bufnr, opts)
          local max_bytes = 10000
          local cmd = { "head", "-c", max_bytes, filepath }
          require("telescope.previewers.utils").job_maker(cmd, bufnr, opts)
        end,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
    },
  })
  telescope.load_extension("fzf")
  telescope.load_extension("projects")
end

return M
