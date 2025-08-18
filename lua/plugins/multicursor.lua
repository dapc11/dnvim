return {
  "multicursor.nvim",
  dir = "/home/epedape/repos_personal/multicursor.nvim",
  dev = true,
  lazy = false,
  keys = {
    { "<C-n>", function() require("multicursor").add_word_under_cursor() end, desc = "Add cursors for word under cursor" },
    { "<C-m>", function() require("multicursor").add_cursor_at_pos() end, desc = "Add cursor at current position" },
    { "<leader>mc", function() require("multicursor").clear_all_cursors() end, desc = "Clear multicursors" },
    { "<M-Right>", function() require("multicursor").mark_next_like_this() end, desc = "Mark next like this" },
    { "<M-Left>", function() require("multicursor").mark_previous_like_this() end, desc = "Mark previous like this" },

    -- New cursor above/below functionality
    { "<C-Up>", function() require("multicursor").add_cursor_above() end, desc = "Add cursor above" },
    { "<C-Down>", function() require("multicursor").add_cursor_below() end, desc = "Add cursor below" },
  },
  config = function(_, opts)
    local multicursor = require("multicursor")

    -- Setup with opts
    multicursor.setup(opts)

    -- Set up Escape handler with proper override
    -- Use autocmd to ensure it's set after all other plugins
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Force override any existing Escape keymaps
        pcall(vim.keymap.del, "n", "<Esc>") -- Delete existing global
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = 0 }) -- Delete existing buffer-local

        -- Set our escape keymap with high priority
        vim.keymap.set("n", "<Esc>", function()
          if multicursor.is_enabled() then
            -- Clear multicursors if enabled
            multicursor.clear_all_cursors()
          else
            -- Execute the original escape behavior (clear search highlights)
            vim.cmd("nohlsearch")
          end
        end, {
          desc = "Clear multicursors or clear search",
          silent = true,
          buffer = false, -- Global keymap
        })
      end,
    })

    -- Also set up the keymap immediately for current buffer
    vim.schedule(function()
      pcall(vim.keymap.del, "n", "<Esc>")
      pcall(vim.keymap.del, "n", "<Esc>", { buffer = 0 })

      vim.keymap.set("n", "<Esc>", function()
        if multicursor.is_enabled() then
          multicursor.clear_all_cursors()
        else
          vim.cmd("nohlsearch")
        end
      end, {
        desc = "Clear multicursors or clear search",
        silent = true,
      })
    end)
  end,
  opts = {
    auto_clear = false, -- Keep cursors after insert mode
    insert_sync = true, -- Sync typing across cursors
    visual_feedback = true, -- Show visual feedback
    highlight = {
      cursor = "MultiCursor",
      visual = "MultiCursorVisual",
    },
  },
}
