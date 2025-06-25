-- Super Tab implementation for blink.cmp
local M = {}

-- Check if completion menu is visible
local function is_completion_visible()
  return require("blink.cmp").is_visible()
end

-- Check if we should trigger completion
local function should_complete()
  local col = vim.fn.col('.') - 1
  local line = vim.fn.getline('.')
  
  -- Don't complete if at beginning of line
  if col == 0 then
    return false
  end
  
  local char_before = line:sub(col, col)
  
  -- Don't complete if previous character is whitespace
  if char_before:match('%s') then
    return false
  end
  
  -- Check if we have at least one non-whitespace character before cursor
  local text_before = line:sub(1, col)
  return text_before:match('%S')
end

-- Super Tab function
function M.super_tab()
  local blink = require("blink.cmp")
  
  -- If completion menu is visible, select next item
  if is_completion_visible() then
    blink.select_next()
    return
  end
  
  -- If we should complete, trigger completion
  if should_complete() then
    blink.show()
    return
  end
  
  -- Otherwise, insert indentation
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-t>', true, false, true), 'n', false)
end

-- Super Shift-Tab function
function M.super_shift_tab()
  local blink = require("blink.cmp")
  
  -- If completion menu is visible, select previous item
  if is_completion_visible() then
    blink.select_prev()
    return
  end
  
  -- Otherwise, do reverse indentation
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-d>', true, false, true), 'n', false)
end

-- Accept completion with Enter
function M.accept_completion()
  local blink = require("blink.cmp")
  
  if is_completion_visible() then
    blink.accept()
  else
    -- Normal enter behavior
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
  end
end

-- Setup function to configure keymaps
function M.setup()
  -- Wait for blink.cmp to be available
  vim.defer_fn(function()
    -- Set up super tab keymaps
    vim.keymap.set('i', '<Tab>', M.super_tab, { 
      desc = 'Super Tab - Complete or indent',
      silent = true,
      noremap = true
    })
    
    vim.keymap.set('i', '<S-Tab>', M.super_shift_tab, { 
      desc = 'Super Shift-Tab - Previous completion or unindent',
      silent = true,
      noremap = true
    })
    
    vim.keymap.set('i', '<CR>', M.accept_completion, { 
      desc = 'Accept completion or normal enter',
      silent = true,
      noremap = true
    })
    
    -- Optional: Escape to close completion menu
    vim.keymap.set('i', '<Esc>', function()
      local blink = require("blink.cmp")
      if is_completion_visible() then
        blink.hide()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
      end
    end, { 
      desc = 'Close completion or normal escape',
      silent = true,
      noremap = true
    })
    
    -- Additional useful keymaps for completion
    vim.keymap.set('i', '<C-Space>', function()
      require("blink.cmp").show()
    end, { 
      desc = 'Trigger completion manually',
      silent = true,
      noremap = true
    })
    
    vim.keymap.set('i', '<C-e>', function()
      require("blink.cmp").hide()
    end, { 
      desc = 'Hide completion menu',
      silent = true,
      noremap = true
    })
  end, 100)
end

return M
