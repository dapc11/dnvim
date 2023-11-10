return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      enable_diagnostics = false,
      enable_git_status = false,
      filesystem = {
        bind_to_cwd = false,
        use_libuv_file_watcher = false,
      },
    },
  },
  {
    "RRethy/vim-illuminate",
    event = "LazyFile",
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("l", "next")
      map("h", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("l", "next", buffer)
          map("h", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "l", desc = "Next Reference" },
      { "h", desc = "Prev Reference" },
    },
  },
  {
    "echasnovski/mini.indentscope",
    opts = {
      draw = { delay = 500 },
    },
  },
}
