local M = {}

function M.config()
  local status_ok, telescope = pcall(require, "telescope")
  if not status_ok then
    return
  end

  local actions = require("telescope.actions")
  local action_layout = require("telescope.actions.layout")
  local putils = require("telescope.previewers.utils")
  local dropdown_config = {
    center = {
      height = 0.4,
      preview_cutoff = 40,
      prompt_position = "top",
      width = 0.7,
    },
  }

  telescope.setup({
    pickers = {
      lsp_references = {
        theme = "dropdown",
        initial_mode = "normal",
        layout_config = dropdown_config,
      },
      lsp_definitions = {
        theme = "dropdown",
        initial_mode = "normal",
        layout_config = dropdown_config,
      },
      lsp_declarations = {
        theme = "dropdown",
        initial_mode = "normal",
        layout_config = dropdown_config,
      },
      lsp_implementations = {
        theme = "dropdown",
        initial_mode = "normal",
        layout_config = dropdown_config,
      },
      find_files = {
        theme = "dropdown",
        previewer = false,
        layout_config = dropdown_config,
      },
      oldfiles = {
        theme = "dropdown",
        previewer = false,
        layout_config = dropdown_config,
      },
      git_files = {
        theme = "dropdown",
        previewer = false,
        layout_config = dropdown_config,
      },
      current_buffer_fuzzy_find = {
        theme = "dropdown",
        layout_config = dropdown_config,
      },
      buffers = {
        theme = "dropdown",
        previewer = false,
        initial_mode = "normal",
        layout_config = dropdown_config,
        mappings = {
          n = {
            ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
            ["dd"] = actions.delete_buffer,
          },
          i = {
            ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
          },
        },
      },
    },
    defaults = {
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      path_display = { "smart" },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      initial_mode = "insert",
      file_ignore_patterns = { "node_modules", "\\.git", ".jar", ".tar.gz", ".zip", ".png", ".jpeg", ".cache" },
      winblend = 0,
      -- border = {},
      -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
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
