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

      -- Comment
      require("mini.comment").setup()

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

      -- Indentscope
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

      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
}
