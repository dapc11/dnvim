return {
  {
    "echasnovski/mini.surround",
    version = "*",
    opts = {
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
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = "*",
    config = function()
      require("mini.indentscope").setup()
    end,
  },
  {
    "echasnovski/mini.ai",
    version = "*",
    config = function()
      require("mini.ai").setup()
    end,
  },
  {
    "echasnovski/mini.statusline",
    version = "*",
    config = function()
      require("mini.statusline").setup()
    end,
  },
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    opts = function()
      local new_section = function(name, action, section)
        return { name = name, action = action, section = section }
      end

      local starter = require("mini.starter")
      local config = {
        evaluate_single = true,
      -- stylua: ignore
      items = {
        new_section("Find file", function () require("util.init").telescope("files")() end, "Telescope"),
        new_section("Recent files", "Telescope oldfiles", "Telescope"),
        new_section("Grep text", "Telescope live_grep", "Telescope"),
        new_section("Projects", "Telescope projects", "Telescope"),
        new_section("Lazy", "Lazy", "Config"),
        new_section("Config", function() require('telescope.builtin').find_files({cwd = vim.fn.stdpath('config')}) end, "Config"),
        new_section("New file", "ene | startinsert", "Built-in"),
        new_section("Quit", "qa", "Built-in"),
        new_section("Session restore", function() require("persistence").load({ last = true }) end, "Session"),
      },
        content_hooks = {
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)
    end,
  },
}