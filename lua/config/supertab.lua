local M = {}

local function is_completion_visible()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then
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
  local blink = require("blink.cmp")

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
  local blink = require("blink.cmp")

  if is_completion_visible() then
    blink.select_prev()
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
end

function M.setup()
  vim.defer_fn(function()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok then
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
        blink.hide()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end, {
      silent = true,
      noremap = true,
    })
  end, 100)
end

return M
