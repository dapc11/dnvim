local M = {}
M.root_patterns = { ".git", "lua", "bob" }

function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.lsp_keymaps()
  local function opts(desc)
    return { buffer = true, noremap = true, silent = true, desc = "LSP: " .. (desc or "") }
  end
  M.map("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
  M.map("n", "gr", vim.lsp.buf.references, opts("Goto References"))
  M.map("n", "<leader>cf", vim.lsp.buf.format, opts("Format"))
  M.map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
  M.map("n", "<leader>cn", vim.lsp.buf.rename, opts("Rename"))
  M.map("n", "<leader>cd", vim.diagnostic.open_float, opts("Show Diagnostic"))
  M.map("n", "]d", vim.diagnostic.goto_next, opts("Next Diagnostic"))
  M.map("n", "[d", vim.diagnostic.goto_prev, opts("Prev Diagnostic"))
  M.map("i", "<C-h>", vim.lsp.buf.signature_help, opts("Show Signature"))
  M.map("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
end

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

---Return project root of project_root_indicator
---@param project_root_indicator string
---@return string
function M.get_project_root(project_root_indicator)
  local current = vim.api.nvim_buf_get_name(0)
  local parent = parent_dir(current)

  while 1 do
    if match(parent, project_root_indicator) then
      return parent
    end

    current, parent = parent, parent_dir(parent)
    if parent == current then
      break
    end
  end
  return ""
end

local function snake_case(str)
  return str:gsub("%s+", "_"):gsub("[^%w_]", ""):lower()
end

function M.create_note()
  local title = vim.fn.input("Note title: ")
  if title == "" then
    return
  end

  local file_name = snake_case(title) .. ".md"
  local notes_dir = vim.fn.expand("~/notes/")

  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end

  local file_path = notes_dir .. file_name
  if vim.fn.filereadable(file_path) == 1 then
    print("File already exists: " .. file_path)
    return
  end

  local file = io.open(file_path, "w")
  if file then
    file:write("# " .. title .. "\n\n")
    file:close()
    print("Note created: " .. file_path)
    vim.cmd("edit " .. file_path)
  else
    print("Error creating note: " .. file_path)
  end
end

return M
