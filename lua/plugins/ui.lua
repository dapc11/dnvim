return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, function(msg)
        msg = msg or "LS Inactive"
        local buf_clients = vim.lsp.get_active_clients()
        if next(buf_clients) == nil then
          if type(msg) == "boolean" or #msg == 0 then
            return "LS Inactive"
          end
          return msg
        end
        local buf_client_names = {}

        for _, client in pairs(buf_clients) do
          if client.name ~= "null-ls" then
            table.insert(buf_client_names, client.name)
          end
        end

        return "  " .. table.concat(vim.fn.uniq(buf_client_names), ", ")
      end)
    end,
  },
}
