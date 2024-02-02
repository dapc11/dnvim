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
    "nvim-telescope/telescope.nvim",
    dependencies = { "dapc11/project.nvim", "dapc11/telescope-yaml.nvim" },
    cmd = "Telescope",
    -- stylua: ignore
    keys = {
      { "<leader>.", function() require("telescope.builtin").buffers() end, desc = "Find Buffer" },
      { "<leader>r", function() require("telescope.builtin").oldfiles() end, desc = "Find Recent Files" },
      { "<leader>n", function() require("telescope.builtin").find_files() end, desc = "Find Tracked Files" },
      { "<leader>N", function() require("telescope.builtin").git_files({ git_command = { "git", "ls-files", "--modified", "--exclude-standard" }, }) end, desc = "Find Untracked Files" },
      { "<leader>lc", function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root, }) end, desc = "Find Plugin File" },
      { "<leader><leader>", function() require("telescope.builtin").live_grep() end, desc = "Grep" },
      { "<leader><leader>", function() require("telescope.builtin").live_grep({ default_text = GetVisualSelection() }) end, desc = "Live Grep Selection", mode = "v" },
      { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Current Buffer" },
      { "<C-f>", function() require("telescope.builtin").current_buffer_fuzzy_find({ default_text = GetVisualSelection() }) end, desc = "Current Buffer Grep Selection", mode = "v" },
      { "<C-p>", function() require("telescope").extensions.projects.projects() end, desc = "Find Project" },
    },
    opts = function()
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")
      local previewers = require("telescope.previewers")

      local new_maker = function(filepath, bufnr, opts)
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
      end
      return {
        pickers = {
          lsp_document_symbols = theme({ symbol_width = 100 }),
          lsp_dynamic_workspace_symbols = theme({ symbol_width = 100 }),
        },
        --   autocommands = theme(),
        --   buffers = theme(),
        --   colorscheme = theme(),
        --   command_history = theme(),
        --   commands = theme(),
        --   current_buffer_tags = theme(),
        --   diagnostics = theme(),
        --   filetypes = theme(),
        --   find_files = theme(),
        --   git_bcommits = theme(),
        --   git_bcommits_range = theme(),
        --   git_branches = theme(),
        --   git_commits = theme(),
        --   git_files = theme(),
        --   git_stash = theme(),
        --   git_status = theme(),
        --   help_tags = theme(),
        --   highlights = theme(),
        --   jumplist = theme(),
        --   keymaps = theme(),
        --   loclist = theme(),
        --   lsp_definitions = theme(),
        --   lsp_implementations = theme(),
        --   lsp_incoming_calls = theme(),
        --   lsp_outgoing_calls = theme(),
        --   lsp_references = theme(),
        --   lsp_type_definitions = theme(),
        --   lsp_workspace_symbols = theme(),
        --   man_pages = theme(),
        --   marks = theme(),
        --   oldfiles = theme(),
        --   pickers = theme(),
        --   quickfix = theme(),
        --   quickfixhistory = theme(),
        --   registers = theme(),
        --   resume = theme(),
        --   search_history = theme(),
        --   spell_suggest = theme(),
        --   tags = theme(),
        --   vim_options = theme(),
        -- },
        -- pickers = theme(borderless_theme()),
        defaults = {
          buffer_previewer_maker = new_maker,
          preview = false,
          sorting_strategy = "ascending",
          winblend = 0,
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
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("projects")
      require("telescope").load_extension("telescope-yaml")
    end,
  },
}
