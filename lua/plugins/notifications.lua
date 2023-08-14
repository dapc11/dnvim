return {
  {
    "rcarriga/nvim-notify",
    opts = {
      max_height = 1,
      render = "compact",
      stages = "static",
      timeout = 1000,
    },
    keys = function()
      return {
        {
          "<C-x>",
          function()
            require("notify").dismiss({ silent = true, pending = true })
          end,
          desc = "Dismiss all Notifications",
        },
      }
    end,
  },
  {
    "folke/noice.nvim",
    keys = function()
      -- Disable <c-f> and <c-b> to not clash with other keymaps
      -- stylua: ignore
      return {
        { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
        { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
        { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
        { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
        { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      }
    end,
  },
}
