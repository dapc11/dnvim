local M = {}
local safe_require = require("util.safe_require")

local function is_completion_visible()
  local blink = safe_require.require("blink.cmp", { silent = true })
  if not blink then
    return false
  end
  return blink.is_visible()
end

local function should_complete()
  local col = vim.fn.col(".") - 1
  local line = vim.fn.getline(".")

  if col == 0 then
    return false
  end

  local char_before = line:sub(col, col)

  if char_before:match("%s") then
    return false
  end

  local text_before = line:sub(1, col)
  return text_before:match("%S")
end

function M.super_tab()
  local blink = safe_require.require("blink.cmp", { silent = true })
  if not blink then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
    return
  end

  if is_completion_visible() then
    blink.select_next()
    return
  end

  if should_complete() then
    blink.show()
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
end

function M.super_shift_tab()
  local blink = safe_require.require("blink.cmp", { silent = true })
  if not blink then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
    return
  end

  if is_completion_visible() then
    blink.select_prev()
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
end

function M.setup()
  local SETUP_DELAY_MS = 100

  vim.defer_fn(function()
    local blink = safe_require.require("blink.cmp", { silent = true })
    if not blink then
      return
    end

    vim.keymap.set("i", "<Tab>", M.super_tab, {
      silent = true,
      noremap = true,
    })

    vim.keymap.set("i", "<S-Tab>", M.super_shift_tab, {
      silent = true,
      noremap = true,
    })

    vim.keymap.set("i", "<Esc>", function()
      if is_completion_visible() then
        local blink = safe_require.require("blink.cmp", { silent = true })
        if blink then
          blink.hide()
        end
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end, {
      silent = true,
      noremap = true,
    })
  end, SETUP_DELAY_MS)
end

return M
