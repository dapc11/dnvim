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
      lsp_references = {
        theme = "dropdown",
      },
      lsp_definitions = {
        theme = "dropdown",
      },
      lsp_declarations = {
        theme = "dropdown",
      },
      lsp_implementations = {
        theme = "dropdown",
      },
      buffers = {
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
      path_display = { "truncate" },
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
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
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
