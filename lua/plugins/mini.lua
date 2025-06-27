return {
  {
    "echasnovski/mini.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      -- Around Inside textobjects
      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })

      -- Surround
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup({
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "",
          find_left = "",
          highlight = "",
          replace = "gsr",
          update_n_lines = "gsn",
          suffix_last = "l",
          suffix_next = "n",
        },
      })

      require("mini.indentscope").setup()

      -- Statusline
      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = true })

      statusline.section_fileinfo = function(_)
        local filetype = vim.bo.filetype

        -- Don't show anything if can't detect file type or not inside a "normal
        -- buffer"
        if (filetype == "") or vim.bo.buftype ~= "" then
          return ""
        end

        -- Add filetype icon
        local has_devicons, devicons = pcall(require, "nvim-web-devicons")
        if has_devicons then
          local file_name, file_ext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
          local icon = devicons.get_icon(file_name, file_ext, { default = true })

          if icon ~= "" then
            filetype = string.format("%s %s", icon, filetype)
          end
        end

        local buf_client_names = {}
        for _, client in pairs(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })) do
          table.insert(buf_client_names, client.name or "")
        end
        local lsp = table.concat(buf_client_names, ", ")

        return string.format("%s [%s]", filetype, lsp)
      end
      local new_section = function(name, action, section)
        return { name = name, action = action, section = section }
      end

      statusline.section_location = function()
        return "%2l:%-2v"
      end

      local starter = require("mini.starter")
      local starter_config = {
        evaluate_single = true,
        items = {
          new_section("Find file", Snacks.picker.files, "Finders"),
          new_section("Recent files", Snacks.picker.recent, "Finders"),
          new_section("Grep text", Snacks.picker.grep, "Finders"),
          new_section("Projects", function()
            Snacks.picker.projects({
              finder = "recent_projects",
              format = "file",
              dev = { "~/repos", "~/.config", "~/repos_personal" },
              patterns = {
                "ruleset2.0.yaml",
                ".git",
                ".gitignore",
                ".hg",
                ".bzr",
                ".svn",
                "package.json",
                "Makefile",
              },
              confirm = "load_session",
              recent = true,
              matcher = {
                frecency = true, -- use frecency boosting
                sort_empty = true, -- sort even when the filter is empty
                cwd_bonus = false,
              },
              sort = { fields = { "score:desc", "idx" } },
              win = {
                preview = { minimal = true },
                input = {
                  keys = {
                    ["<c-f>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
                    ["<CR>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
                    ["<c-g>"] = { { "tcd", "picker_grep" }, mode = { "n", "i" } },
                    ["<c-r>"] = { { "tcd", "picker_recent" }, mode = { "n", "i" } },
                    ["<c-w>"] = { { "tcd" }, mode = { "n", "i" } },
                    ["<c-t>"] = {
                      function(picker)
                        vim.cmd("tabnew")
                        Snacks.notify("New tab opened")
                        picker:close()
                        Snacks.picker.projects()
                      end,
                      mode = { "n", "i" },
                    },
                  },
                },
              },
            })
          end, "Finders"),
          new_section("Git", "Git", "Git"),
          new_section("Lazy", "Lazy", "Config"),
          new_section("Config", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "Config"),
          new_section("New file", "ene | startinsert", "Built-in"),
          -- new_section("Quit", "qa", "Built-in"),
          new_section("Session restore", function()
            require("persistence").load({ last = true })
          end, "Session"),
        },
        content_hooks = {
          starter.gen_hook.aligning("center", "center"),
        },
      }

      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      starter.setup(starter_config)
    end,
  },
}
