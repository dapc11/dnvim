local GetVisualSelection = require("util.common").GetVisualSelection
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      {
        "dapc11/telescope-yaml.nvim",
        config = function()
          require("telescope").load_extension("telescope-yaml")
        end,
      },
      {
        "dapc11/project.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        keys = {
          {
            "<C-p>",
            function()
              require("telescope").extensions.projects.projects()
            end,
            desc = "Find Project",
          },
        },
        config = function(_, opts)
          require("project_nvim").setup(opts)
          require("telescope").load_extension("projects")
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
            "package.json",
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
    },
    keys = {
      { "<leader>/", false },
      {
        "<leader>r",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Find Recent Files",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").find_files({
            cwd = "~/repos/",
            path_display = { "truncate", shorten = { len = 1, exclude = { 1, -1, -2 } } },
            prompt_title = "Repos",
            layout_config = {
              height = 0.85,
            },
          })
        end,
        desc = "Find file in repos",
      },
      -- git
      { "<leader>gC", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gS", "<cmd>Telescope git_status<CR>", desc = "status" },
      { "<leader>gB", "<cmd>Telescope git_branches<CR>", desc = "branches" },
      {
        "<leader>n",
        require("lazyvim.util").telescope("files"),
        desc = "Find Tracked Files",
      },
      {
        "<leader>N",
        function()
          require("telescope.builtin").git_files({
            git_command = { "git", "ls-files", "--modified", "--exclude-standard" },
          })
        end,
        desc = "Find Untracked Files",
      },
      { "<leader><leader>", require("lazyvim.util").telescope("live_grep"), desc = "Grep" },
      {
        "<leader><leader>",
        function()
          require("telescope.builtin").live_grep({ default_text = GetVisualSelection() })
        end,
        desc = "Live Grep Selection",
        mode = "v",
      },
      { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Current Buffer" },
      {
        "<C-f>",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({ default_text = GetVisualSelection() })
        end,
        desc = "Current Buffer Grep Selection",
        mode = "v",
      },
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
        defaults = {
          buffer_previewer_maker = new_maker,
          preview = false,
          -- layout_config = {
          --   width = 0.50,
          --   height = 0.60,
          --   prompt_position = "top",
          --   preview_cutoff = 80,
          -- },
          sorting_strategy = "ascending",
          path_display = function(_, inputPath)
            -- Function to check if a table contains a value
            local function tableContains(table, value)
              for _, v in ipairs(table) do
                if v == value then
                  return true
                end
              end
              return false
            end
            local prefix = string.sub(inputPath, 1, 3)
            if
              (prefix == "v3/" or prefix == "v4/")
              and string.find(inputPath, "kubernetes/pods/logs")
              and string.find(inputPath, ".txt")
            then
              -- Split the path into segments using "/"
              local segments = {}
              for segment in string.gmatch(inputPath, "[^/]+") do
                table.insert(segments, segment)
              end

              -- Define the indexes to exclude
              local excludeIndexes = { 2, 3, 4, 6, 7 }
              -- Create a new path by excluding segments at specified indexes
              local newPath = ""
              for i, segment in ipairs(segments) do
                if not tableContains(excludeIndexes, i) then
                  if newPath == "" then
                    newPath = segment
                  else
                    newPath = newPath .. "/" .. segment
                  end
                end
              end

              return newPath
            else
              return inputPath
            end
          end,
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
  },
}
