local M = {}
M.root_patterns = { ".git", "lua" }

function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param command string
function M.format(command)
  local function buf_get_full_text()
    local bufnr = vim.fn.bufnr()
    local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")
    if vim.api.nvim_buf_get_option(bufnr, "eol") then
      text = text .. "\n"
    end
    return text
  end

  local input = buf_get_full_text()
  local output = vim.fn.system(command .. " 2>/dev/null", input)

  if vim.fn.empty(output) == 0 and output ~= input then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.split(output, "\n"))
  end
end

return M
