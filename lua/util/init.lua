local M = {}
M.root_patterns = { ".git", "lua", "bob" }

function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param value any
---@param opts? {loc:string, bt?:boolean}
function M._dump(value, opts)
  opts = opts or {}
  opts.loc = opts.loc or ""
  if vim.in_fast_event() then
    return vim.schedule(function()
      M._dump(value, opts)
    end)
  end
  opts.loc = vim.fn.fnamemodify(opts.loc, ":~:.")
  local msg = vim.inspect(value)
  if opts.bt then
    msg = msg .. "\n" .. debug.traceback("", 2)
  end
  vim.notify(msg, vim.log.levels.INFO, {
    title = "Debug: " .. opts.loc,
    on_open = function(win)
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = ""
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, "lua") then
        vim.bo[buf].filetype = "lua"
      end
    end,
  })
end
function M.dump(...)
  local value = { ... }
  if vim.tbl_isempty(value) then
    value = {}
  else
    value = vim.islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
  end
  M._dump(value)
end

function M.bt(...)
  local value = { ... }
  if vim.tbl_isempty(value) then
    value = {}
  else
    value = vim.islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
  end
  M._dump(value, { bt = true })
end

function M.lsp_keymaps()
  local function opts(desc)
    return { buffer = true, noremap = true, silent = true, desc = "LSP: " .. (desc or "") }
  end
  M.map("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
  M.map("n", "gr", vim.lsp.buf.references, opts("Goto References"))
  M.map("n", "<leader>cc", vim.lsp.buf.format, opts("Format"))
  M.map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
  M.map("n", "<leader>cn", vim.lsp.buf.rename, opts("Rename"))
  M.map("n", "<leader>d", vim.diagnostic.open_float, opts("Show Diagnostic"))
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

-- Utility function to convert a string to snake_case
local function snake_case(str)
  return str:gsub("%s+", "_"):gsub("[^%w_]", ""):lower()
end

-- Function to prompt for title, create the note, and populate it
function M.create_note()
  -- Prompt the user for a title
  local title = vim.fn.input("Note title: ")

  -- If the user cancels the input, return early
  if title == "" then
    return
  end

  -- Convert the title to snake_case for the file name
  local file_name = snake_case(title) .. ".md"

  -- Define the path to the notes directory
  local notes_dir = vim.fn.expand("~/notes/")

  -- Create the notes directory if it doesn't exist
  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end

  -- Define the full path to the new file
  local file_path = notes_dir .. file_name

  -- Check if the file already exists, to avoid overwriting
  if vim.fn.filereadable(file_path) == 1 then
    print("File already exists: " .. file_path)
    return
  end

  -- Create and write to the new markdown file
  local file = io.open(file_path, "w")
  if file then
    -- Write the title as a markdown header
    file:write("# " .. title .. "\n\n")
    file:close()
    print("Note created: " .. file_path)
    -- Open the file in a new buffer
    vim.cmd("edit " .. file_path)
  else
    print("Error creating note: " .. file_path)
  end
end

return M
