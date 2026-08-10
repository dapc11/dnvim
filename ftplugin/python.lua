local get_root = require("util.init").get_project_root

local pythonpath_file = ".pythonpath"
local root = get_root(pythonpath_file)

if root == nil then
  vim.env.PYTHONPATH = nil
else
  local absolute_path = root .. "/" .. pythonpath_file
  local handle = io.open(absolute_path, "r")
  if handle then
    local python_path = ""
    for line in handle:lines() do
      if vim.startswith(line, "/home/") then
        python_path = python_path .. line .. ":"
      else
        python_path = python_path .. root .. "/" .. line .. ":"
      end
    end
    handle:close()
    vim.env.PYTHONPATH = python_path
  else
    vim.env.PYTHONPATH = nil
  end
end

local fzf = require("fzf-lua")
vim.keymap.set("n", "gf", function()
  vim.cmd('noau normal! "vyiw')
  fzf.grep_project({
    search = "def " .. vim.fn.getreg("v") .. "(",
    path_shorten = true,
  })
end, { desc = "Goto Fixture", buffer = true })

vim.keymap.set("n", "gR", function()
  fzf.grep_project({ search = vim.fn.expand("<cword>"), path_shorten = true })
end, { desc = "Find Usages Under Cursor", buffer = true })
