local function match(dir, pattern)
  if string.sub(pattern, 1, 1) == "=" then
    return vim.fn.fnamemodify(dir, ":t") == string.sub(pattern, 2, #pattern)
  else
    return vim.fn.globpath(dir, pattern) ~= ""
  end
end

local function parent_dir(dir)
  return vim.fn.fnamemodify(dir, ":h")
end

local function get_root(pythonpath_file)
  local current = vim.api.nvim_buf_get_name(0)
  local parent = parent_dir(current)

  while 1 do
    if match(parent, pythonpath_file) then
      return parent
    end

    current, parent = parent, parent_dir(parent)
    if parent == current then
      break
    end
  end
  return nil
end

local function file_exists(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

local pythonpath_file = ".pythonpath"
local root = get_root(pythonpath_file)

if root == nil then
  vim.env.PYTHONPATH = nil
else
  local absolute_path = root .. "/" .. pythonpath_file
  local python_path = ""
  if file_exists(absolute_path) then
    for line in io.open(absolute_path):lines() do
      python_path = python_path .. root .. "/" .. line .. ":"
    end
    vim.env.PYTHONPATH = python_path
  else
    vim.env.PYTHONPATH = nil
  end
end

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>cgf", require("pytrize.api").jump_fixture, { desc = "Jump to Fixture", buffer = bufnr })
vim.keymap.set("n", "<leader>cgp", require("pytrize.api").jump, { desc = "Jump to Parameterized", buffer = bufnr })
vim.keymap.set("n", "<leader>cv", "<cmd>:VenvSelect<cr>", { desc = "Select VirtualEnv", buffer = bufnr })
vim.keymap.set("n", "<leader>tm", require("dap-python").test_method, { desc = "Debug Method", buffer = bufnr })
vim.keymap.set("n", "<leader>tc", require("dap-python").test_class, { desc = "Debug Class", buffer = bufnr })
vim.keymap.set("n", "<leader>dm", require("dap-python").test_method, { desc = "Debug Method", buffer = bufnr })
vim.keymap.set("n", "<leader>dc", require("dap-python").test_class, { desc = "Debug Class", buffer = bufnr })
