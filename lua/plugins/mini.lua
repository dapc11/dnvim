return {
  {
    "echasnovski/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
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
    version = false, -- wait till new 0.7.0 release to put it back on semver
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
      -- close Lazy and re-open when starter is ready
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
