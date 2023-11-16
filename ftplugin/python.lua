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
vim.keymap.set(
  "n",
  "ccq",
  "<cmd>new | 0read !black --config pyproject.toml #<cr>",
  { desc = "Run Black for Current Buffer", buffer = bufnr }
)
vim.keymap.set("n", "ccw", "<cmd>new | 0read !bandit #<cr>", { desc = "Run Bandit for Current Buffer", buffer = bufnr })
vim.keymap.set(
  "n",
  "cce",
  "<cmd>new | 0read !flake8 --ignore C812,E501 #<cr><cr>",
  { desc = "Run Flake8 for Current Buffer", buffer = bufnr }
)
vim.keymap.set(
  "n",
  "ccr",
  "<cmd>new | 0read !pylint --disable W4901 #<cr><cr>",
  { desc = "Run Pylint for Current Buffer", buffer = bufnr }
)
function RunCodeQualityChecks()
  local current_file = vim.fn.expand("%:p") -- Get the full path of the current file

  local output_buffer = vim.api.nvim_create_buf(false, true) -- Create a new scratch buffer

  local function run_command(command)
    local data = vim.fn.system(command .. " " .. current_file .. " 2>/dev/null")

    print("Code quality check (" .. command .. ") executed")
    if data ~= "" then
      vim.api.nvim_buf_set_lines(output_buffer, -1, -1, false, { "##############", command, "##############" })
      vim.api.nvim_buf_set_lines(output_buffer, -1, -1, false, vim.fn.split(data, "\n"))
    else
      print("Code quality check (" .. command .. ") passed")
    end
  end

  run_command("black --check --config pyproject.toml")
  run_command("flake8 --ignore C812,E501")
  run_command("bandit -r")
  run_command("pylint --disable W4901")

  vim.api.nvim_command("vertical sb " .. vim.fn.bufnr(output_buffer))
end

vim.api.nvim_set_keymap("n", "<leader>cq", [[:lua RunCodeQualityChecks()<CR>]], { noremap = true, silent = true })
