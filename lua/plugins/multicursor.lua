return {
  "multicursor.nvim",
  dir = "/home/epedape/repos_personal/multicursor.nvim",
  dev = true,
  keys = {
    { "<C-n>", function() require("multicursor").add_word_under_cursor() end, desc = "Add cursors for word under cursor" },
    { "<C-m>", function() require("multicursor").add_cursor_at_pos() end, desc = "Add cursor at current position" },
    { "<Esc>", function() require("multicursor").clear_all_cursors() end, desc = "Clear multicursors" },
    { "<M-Right>", function() require("multicursor").mark_next_like_this() end, desc = "Mark next like this" },
    { "<M-Left>", function() require("multicursor").mark_previous_like_this() end, desc = "Mark previous like this" },
    { "<leader>ma", function() require("multicursor").add_cursors_to_visual_selection() end, mode = "v", desc = "Add cursors to all visual matches" },
    { "<leader>mn", function() require("multicursor").add_cursor_to_next_visual() end, mode = "v", desc = "Add cursor to next visual match" },
    { "<leader>mp", function() require("multicursor").add_cursor_to_prev_visual() end, mode = "v", desc = "Add cursor to prev visual match" },
  },
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
