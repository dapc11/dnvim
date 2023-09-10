return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    lazy = false,
    version = false,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      {
        "dapc11/telescope-yaml.nvim",
        config = function()
          require("telescope").load_extension("telescope-yaml")
        end,
      },
      {
        "dapc11/project.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        lazy = false,
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
    keys = function()
      local Util = require("util")
      local function getVisualSelection()
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg("v")
        vim.fn.setreg("v", {})

        text = string.gsub(text, "\n", "")
        if #text > 0 then
          return text
        else
          return ""
        end
      end

      return {
        { "<C-p>", "<cmd>Telescope projects<cr>", desc = "Find Project" },
        { "<leader>fn", "<CMD>Telescope notify<cr>", desc = "Notifications" },
        -- find
        { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
        { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },
        -- search
        {
          "<leader>sa",
          "<cmd>Telescope autocommands<cr>",
          desc = "Auto Commands",
        },
        {
          "<leader><leader>",
          function()
            require("telescope.builtin").live_grep({ default_text = getVisualSelection() })
          end,
          desc = "Live Grep Selection",
          mode = "v",
        },
        {
          "<C-f>",
          function()
            require("telescope.builtin").current_buffer_fuzzy_find({ default_text = getVisualSelection() })
          end,
          desc = "Current Buffer Grep Selection",
          mode = "v",
        },
      }
    end,
    opts = function()
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")
      local trouble = require("trouble.providers.telescope")
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
          layout_strategy = "vertical",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          winblend = 0,
          -- stylua: ignore
          mappings = {
            i = {
              ["<C-q>"] = function(...)
                return trouble.smart_open_with_trouble(...)
              end,
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
              ["<C-q>"] = function(...)
                return trouble.smart_open_with_trouble(...)
              end,
              ["<C-down>"] = actions.cycle_history_next,
              ["<C-up>"] = actions.cycle_history_prev,
            },
          },
        },
      }
    end,
  },
}
