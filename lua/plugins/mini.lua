return {
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Around Inside textobjects
      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      local MAX_LINES_FOR_AI_SEARCH = 500 -- Maximum lines to search for text objects
      require("mini.ai").setup({ n_lines = MAX_LINES_FOR_AI_SEARCH })

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
      local fzf = require("fzf-lua")
      local fzfe = require("fzf-lua-enchanted-files")

      local starter_config = {
        evaluate_single = true,
        items = {
          new_section("Find file", fzfe.files, "Finders"),
          new_section("Recent files", fzf.oldfiles, "Finders"),
          new_section("Grep text", fzf.live_grep, "Finders"),
          new_section("Projects", function()
            require("util.common").fzf_projectionist()
          end, "Finders"),
          new_section("Git", "Git", "Git"),
          new_section("Lazy", "Lazy", "Config"),
          new_section("Config", function()
            fzfe.files({ cwd = "~/.config/nvim/" })
          end, "Config"),
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
