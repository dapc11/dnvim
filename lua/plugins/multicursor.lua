return {
  "multicursor.nvim",
  dir = "/home/epedape/repos_personal/multicursor.nvim",
  dev = true,
  lazy = false,
  keys = {
    { "<C-n>", function() require("multicursor").add_word_under_cursor() end, desc = "Add cursors for word under cursor" },
    { "<C-m>", function() require("multicursor").add_cursor_at_pos() end, desc = "Add cursor at current position" },
    { "<C-x>", function() require("multicursor").skip_word_occurrence() end, desc = "Skip current word occurrence" },
    { "<C-p>", function() require("multicursor").goto_prev_cursor() end, desc = "Go to previous cursor" },
    { "<C-j>", function() require("multicursor").goto_next_cursor() end, desc = "Go to next cursor" },
    
    -- Use a different key for clearing cursors to avoid conflicts
    { "<leader>mc", function() require("multicursor").clear_all_cursors() end, desc = "Clear multicursors" },
    
    -- Emacs-style incremental selection
    { "<M-Right>", function() require("multicursor").mark_next_like_this() end, desc = "Mark next like this" },
    { "<M-Left>", function() require("multicursor").mark_previous_like_this() end, desc = "Mark previous like this" },
    
    -- Visual selection based
    { "<leader>ma", function() require("multicursor").add_cursors_to_visual_selection() end, mode = "v", desc = "Add cursors to all visual matches" },
    { "<leader>mn", function() require("multicursor").add_cursor_to_next_visual() end, mode = "v", desc = "Add cursor to next visual match" },
    { "<leader>mp", function() require("multicursor").add_cursor_to_prev_visual() end, mode = "v", desc = "Add cursor to prev visual match" },
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
        pcall(vim.keymap.del, 'n', '<Esc>')  -- Delete existing global
        pcall(vim.keymap.del, 'n', '<Esc>', { buffer = 0 })  -- Delete existing buffer-local
        
        -- Set our escape keymap with high priority
        vim.keymap.set('n', '<Esc>', function()
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
          buffer = false  -- Global keymap
        })
      end
    })
    
    -- Also set up the keymap immediately for current buffer
    vim.schedule(function()
      pcall(vim.keymap.del, 'n', '<Esc>')
      pcall(vim.keymap.del, 'n', '<Esc>', { buffer = 0 })
      
      vim.keymap.set('n', '<Esc>', function()
        if multicursor.is_enabled() then
          multicursor.clear_all_cursors()
        else
          vim.cmd("nohlsearch")
        end
      end, { 
        desc = "Clear multicursors or clear search", 
        silent = true 
      })
    end)
    
    -- Enhanced MC command with multiple modes
    vim.api.nvim_create_user_command("MC", function(cmd_opts)
      local args = vim.split(cmd_opts.args, "%s+")
      local mode = args[1]
      local pattern = args[2]
      
      if mode == "word" or (not pattern and mode) then
        -- Default: search for word occurrences
        local word = pattern or mode
        if word and word ~= "" then
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local cursor_count = 0
          
          for line_num, line in ipairs(lines) do
            local start_col = 1
            while true do
              local start_pos, end_pos = string.find(line, vim.pesc(word), start_col, false)
              if not start_pos then break end
              
              multicursor.add_cursor(line_num, start_pos - 1)
              cursor_count = cursor_count + 1
              start_col = end_pos + 1
            end
          end
          
          if cursor_count > 0 then
            multicursor.enable()
            vim.notify(string.format("Added %d cursors for '%s'", cursor_count, word))
          else
            vim.notify(string.format("No matches found for '%s'", word))
          end
        else
          vim.notify("Usage: :MC <word> or :MC word <pattern>")
        end
        
      elseif mode == "regex" and pattern then
        -- Regex pattern matching
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cursor_count = 0
        
        for line_num, line in ipairs(lines) do
          local start_col = 1
          while start_col <= #line do
            local start_pos, end_pos = string.find(line, pattern, start_col)
            if not start_pos then break end
            
            multicursor.add_cursor(line_num, start_pos - 1)
            cursor_count = cursor_count + 1
            start_col = end_pos + 1
          end
        end
        
        if cursor_count > 0 then
          multicursor.enable()
          vim.notify(string.format("Added %d cursors for pattern '%s'", cursor_count, pattern))
        else
          vim.notify(string.format("No matches found for pattern '%s'", pattern))
        end
        
      elseif mode == "line" and pattern then
        -- Add cursor to specific line numbers
        local line_nums = vim.split(pattern, ",")
        local cursor_count = 0
        local line_count = vim.api.nvim_buf_line_count(0)
        
        for _, line_str in ipairs(line_nums) do
          local line_num = tonumber(line_str)
          if line_num and line_num >= 1 and line_num <= line_count then
            multicursor.add_cursor(line_num, 0)
            cursor_count = cursor_count + 1
          end
        end
        
        if cursor_count > 0 then
          multicursor.enable()
          vim.notify(string.format("Added %d cursors to lines", cursor_count))
        else
          vim.notify("No valid line numbers provided")
        end
        
      elseif mode == "clear" then
        -- Clear all cursors
        multicursor.clear_cursors()
        vim.notify("Cleared all cursors")
        
      else
        -- Show help
        vim.notify([[
MC Command Usage:
  :MC <word>              - Add cursors to all word occurrences
  :MC word <pattern>      - Add cursors to word pattern
  :MC regex <pattern>     - Add cursors using regex pattern
  :MC line <nums>         - Add cursors to line numbers (e.g., "1,5,10")
  :MC clear               - Clear all cursors
        ]], vim.log.levels.INFO)
      end
    end, { 
      nargs = "*",
      desc = "Multicursor operations",
      complete = function(ArgLead, CmdLine, CursorPos)
        local args = vim.split(CmdLine, "%s+")
        if #args <= 2 then
          return {"word", "regex", "line", "clear"}
        end
        return {}
      end
    })
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
