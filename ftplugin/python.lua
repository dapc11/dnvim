local get_root = require("util.init").get_project_root

local function file_exists(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

local pythonpath_file = ".pythonpath"
local root = get_root(pythonpath_file)

function string.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

if root == nil then
  vim.env.PYTHONPATH = nil
else
  local absolute_path = root .. "/" .. pythonpath_file
  local python_path = ""
  if file_exists(absolute_path) then
    for line in io.open(absolute_path):lines() do
      if string.starts(line, "/home/") then
        python_path = python_path .. line .. ":"
      else
        python_path = python_path .. root .. "/" .. line .. ":"
      end
    end
    vim.env.PYTHONPATH = python_path
  else
    vim.env.PYTHONPATH = nil
  end
end

vim.cmd("hi link @string.documentation.python SpecialComment")

vim.keymap.set("n", "gf", function()
  vim.cmd('noau normal! "vyiw')
  require("fzf-lua").grep_project({
    search = "def " .. vim.fn.getreg("v") .. "(",
    path_shorten = true,
  })
end, { desc = "Goto Fixture", buffer = true })

vim.keymap.set("n", "gR", function()
  require("fzf-lua").grep_project({ search = vim.fn.expand("<cword>"), path_shorten = true })
end, { desc = "Find Usages Under Cursor", buffer = true })
