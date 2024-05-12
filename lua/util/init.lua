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
  opts.loc = opts.loc or M.get_loc()
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
    value = nil
  else
    value = vim.tbl_islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
  end
  M._dump(value)
end

function M.bt(...)
  local value = { ... }
  if vim.tbl_isempty(value) then
    value = nil
  else
    value = vim.tbl_islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
  end
  M._dump(value, { bt = true })
end

-- stylua: ignore
function M.lsp_keymaps()
  local function opts(desc)
    return { buffer = true, noremap = true, silent = true, desc = "LSP: " .. desc or "" }
  end
  local fzf = require("fzf-lua")
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Goto References"))
  vim.keymap.set("n", "<leader>cs", fzf.lsp_document_symbols , opts("Workspace Symbols"))
  vim.keymap.set("n", "<leader>cc", function() require("conform").format() end, opts("Format"))
  vim.keymap.set("n", "<leader>cf", fzf.lsp_finder, opts("Finder"))
  vim.keymap.set({"n", "v"}, "<leader>ca", fzf.lsp_code_actions, opts("Code Action"))
  vim.keymap.set("n", "<leader>cn", vim.lsp.buf.rename, opts("Rename"))
  vim.keymap.set("n", "<leader>cd",  fzf.diagnostics_document, opts("Document Diagnostics"))
  vim.keymap.set("n", "<leader>cD",  fzf.diagnostics_workspace, opts("Workspace Diagnostics"))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("Next Diagnostic"))
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("Prev Diagnostic"))
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("Show Signature"))
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
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
  return nil
end

return M
