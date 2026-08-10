local set_win_opts = require("util").set_win_opts

local items = {
  {
    key = "f",
    name = "Find file (cwd)",
    action = function()
      require("fzf-lua-enchanted-files").files()
    end,
  },
  {
    key = "F",
    name = "Find file (~)",
    action = function()
      require("fzf-lua-enchanted-files").files({ cwd = "~" })
    end,
  },
  {
    key = "e",
    name = "Explore (cwd)",
    action = function()
      require("oil").open()
    end,
  },
  {
    key = "E",
    name = "Explore (~)",
    action = function()
      require("oil").open("~")
    end,
  },
  {
    key = "v",
    name = "Version control",
    action = "Git",
  },
  {
    key = "g",
    name = "Grep (cwd)",
    action = function()
      vim.api.nvim_feedkeys(":grep ", "n", false)
    end,
  },
  {
    key = "G",
    name = "Grep (~)",
    action = function()
      vim.ui.input({ prompt = "Grep ~: " }, function(pattern)
        if pattern and pattern ~= "" then
          vim.cmd("grep " .. vim.fn.fnameescape(pattern) .. " ~/**")
        end
      end)
    end,
  },
  {
    key = "r",
    name = "Recent files",
    action = function()
      require("user.fzf-recent-files")()
    end,
  },
  {
    key = "p",
    name = "Projects",
    action = function()
      require("user.fzf-projectionist")()
    end,
  },
  { key = "l", name = "Lazy", action = "Lazy" },
  {
    key = "c",
    name = "Config",
    action = function()
      require("fzf-lua-enchanted-files").files({ cwd = "~/.config/nvim/" })
    end,
  },
  {
    key = "x",
    name = "Scratch buffer",
    action = function()
      vim.cmd("edit " .. vim.fn.expand("~/nvim-scratch.txt"))
    end,
  },
  { key = "n", name = "New file", action = "ene | startinsert" },
  {
    key = "s",
    name = "Session restore",
    action = function()
      require("persistence").load({ last = true })
    end,
  },
  { key = "q", name = "Quit", action = "quit" },
}

local raw_lines = {}
for _, item in ipairs(items) do
  raw_lines[#raw_lines + 1] = ("  [%s]  %s"):format(item.key, item.name)
end

local max_len = 0
for _, line in ipairs(raw_lines) do
  max_len = math.max(max_len, #line)
end

local function render(buf, win)
  local win_w = vim.api.nvim_win_get_width(win)
  local win_h = vim.api.nvim_win_get_height(win)
  local prefix = string.rep(" ", math.max(0, math.floor((win_w - max_len) / 2)))
  local padded = {}
  for _ = 1, math.max(0, math.floor((win_h - #raw_lines) / 2)) do
    padded[#padded + 1] = ""
  end
  for _, line in ipairs(raw_lines) do
    padded[#padded + 1] = prefix .. line
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)
  vim.bo[buf].modifiable = false
end

local function open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "dashboard"
  set_win_opts(0, { number = false, relativenumber = false, colorcolumn = "" })

  local augroup = vim.api.nvim_create_augroup("DashboardResize", { clear = true })

  vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    buffer = buf,
    once = true,
    callback = function()
      vim.api.nvim_del_augroup_by_id(augroup)
      set_win_opts(0, { number = true, relativenumber = true, colorcolumn = "80" })
    end,
  })

  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = augroup,
    buffer = buf,
    callback = function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      -- bufwinid returns -1 when the buffer is not displayed, and every
      -- window API call rejects that as an invalid window id.
      local win = vim.fn.bufwinid(buf)
      if win ~= -1 then
        render(buf, win)
      end
    end,
  })

  render(buf, 0)

  for _, item in ipairs(items) do
    vim.keymap.set("n", item.key, function()
      if type(item.action) == "string" then
        vim.cmd(item.action)
      else
        item.action()
      end
    end, { buffer = buf, nowait = true, silent = true })
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and not vim.g.started_with_stdin and vim.bo.filetype ~= "lazy" then
      open()
    end
  end,
})

vim.api.nvim_create_autocmd("StdinReadPre", {
  callback = function()
    vim.g.started_with_stdin = true
  end,
})

return { open = open }
