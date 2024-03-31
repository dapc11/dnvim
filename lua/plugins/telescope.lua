local GetVisualSelection = require("util.common").GetVisualSelection

local function theme(opts)
  local resolve = require("telescope.config.resolve")
  local lopts = vim.tbl_extend("force", {
    results_title = "",
    layout_config = {
      height = resolve.resolve_height({ 0.3, max = 50, min = 5 }),
    },
  }, opts or {})
  return require("telescope.themes").get_ivy(lopts)
end
return {
  { "dapc11/telescope-yaml.nvim", ft = { "yaml" } },
  {
    "dapc11/project.nvim",
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
    opts = {
      active = true,
      on_config_done = nil,
      manual_mode = false,
      detection_methods = { "pattern" },
      patterns = {
        "ruleset2.0.yaml",
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "script_version.txt",
        "drc-report",
        "image-design-rule-check-report.html",
      },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = true,
      silent_chdir = true,
      scope_chdir = "global",
      datapath = vim.fn.stdpath("data"),
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "dapc11/project.nvim", "dapc11/telescope-yaml.nvim" },
    cmd = "Telescope",
    -- stylua: ignore
    keys = {
      { "<leader>gc", require("telescope.builtin").git_branches, desc = "Checkout Branch" },
      { "<leader>r", require("telescope.builtin").oldfiles, desc = "Find Recent Files" },
      { "<leader>n", require("telescope.builtin").find_files, desc = "Find Tracked Files" },
      { "<leader>N", function() require("telescope.builtin").git_files({ git_command = { "git", "ls-files", "--modified", "--exclude-standard" }, }) end, desc = "Find Untracked Files" },
      { "<leader>lc", function() require("telescope.builtin").find_files({ cwd = "~/.config", }) end, desc = "Find in Dotfiles" },
      { "<leader>lC", function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root, }) end, desc = "Find Plugin File" },
      { "<leader>lh", require("telescope.builtin").help_tags, desc = "Find Help" },
      { "<leader><leader>", require("telescope.builtin").live_grep, desc = "Grep" },
      { "<leader>f", function() require("telescope.builtin").grep_string({ search = ""}) end, desc = "Grep" },
      { "<leader><leader>", function() require("telescope.builtin").grep_string({ search = GetVisualSelection() }) end, desc = "Live Grep Selection", mode = "v" },
      { "<C-f>", require("telescope.builtin").current_buffer_fuzzy_find, desc = "Find in Current Buffer" },
      { "<C-f>", function() require("telescope.builtin").current_buffer_fuzzy_find({ default_text = GetVisualSelection() }) end, desc = "Current Buffer Grep Selection", mode = "v" },
      { "<C-p>", function() require("telescope").extensions.projects.projects() end, desc = "Find Project" },
    },
    opts = function()
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")
      local previewers = require("telescope.previewers")

      return {
        pickers = {
          git_branches = {
            mappings = {
              i = {
                ["<C-d>"] = "preview_scrolling_down",
              },
            },
            previewer = require("telescope.previewers").new_termopen_previewer({
              get_command = function(entry)
                return {
                  "git",
                  "log",
                  "--pretty=format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset",
                  "--max-count",
                  "50",
                  "--abbrev-commit",
                  "--date=relative",
                  entry.value,
                }
              end,
            }),
          },
          lsp_document_symbols = theme({ symbol_width = 100 }),
          lsp_dynamic_workspace_symbols = theme({ symbol_width = 100 }),
        },
        defaults = {
          buffer_previewer_maker = function(filepath, bufnr, opts)
            opts = opts or {}

            filepath = vim.fn.expand(filepath)
            vim.loop.fs_stat(filepath, function(_, stat)
              if not stat then
                return
              end
              if stat.size > 100000 then
                return
              else
                previewers.buffer_previewer_maker(filepath, bufnr, opts)
              end
            end)
          end,
          preview = false,
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<C-p>"] = layout.toggle_preview,
              ["<Esc>"] = actions.close,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<CR>"] = actions.select_default,
              ["<C-h>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.move_selection_better + actions.toggle_selection,
            },
            n = {
              ["<C-c>"] = actions.close,
              ["<C-p>"] = layout.toggle_preview,
              ["<C-down>"] = actions.cycle_history_next,
              ["<C-up>"] = actions.cycle_history_prev,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("projects")
      require("telescope").load_extension("telescope-yaml")
    end,
  },
}
