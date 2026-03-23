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
    action = function()
      require("plugins.git").git_status_fn()
    end,
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
      require("util.fzf-custom-pickers").setup_recent_files()()
    end,
  },
  {
    key = "p",
    name = "Projects",
    action = function()
      require("util.fzf-custom-pickers").create_projectionist_picker()()
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

local function open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "dashboard"
  vim.wo[0].number = false
  vim.wo[0].relativenumber = false
  vim.wo[0].colorcolumn = ""

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function()
      vim.wo[0].number = true
      vim.wo[0].relativenumber = true
      vim.wo[0].colorcolumn = "80"
    end,
  })

  local lines = {}
  for _, item in ipairs(items) do
    table.insert(lines, ("  [%s]  %s"):format(item.key, item.name))
  end

  local max_len = 0
  for _, line in ipairs(lines) do
    max_len = math.max(max_len, #line)
  end

  local win_w = vim.api.nvim_win_get_width(0)
  local left_pad = math.max(0, math.floor((win_w - max_len) / 2))
  local prefix = string.rep(" ", left_pad)

  local padded = {}
  local win_h = vim.api.nvim_win_get_height(0)
  local vpad = math.max(0, math.floor((win_h - #lines) / 2))
  for _ = 1, vpad do
    padded[#padded + 1] = ""
  end
  for _, line in ipairs(lines) do
    padded[#padded + 1] = prefix .. line
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)
  vim.bo[buf].modifiable = false

  for _, item in ipairs(items) do
    vim.keymap.set("n", item.key, function()
      if type(item.action) == "string" then
        vim.cmd(item.action)
      else
        item.action()
      end
    end, { buffer = buf, nowait = true, silent = true })
  end

  vim.keymap.set("n", "<C-p>", function()
    require("util.common").fzf_projectionist()
  end, { buffer = buf })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.bo.filetype ~= "lazy" then
      open()
    end
  end,
})

return { open = open }
