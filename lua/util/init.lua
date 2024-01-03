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

function M.get_loc()
  local me = debug.getinfo(1, "S")
  local level = 2
  local info = debug.getinfo(level, "S")
  while info and (info.source == me.source or info.source == "@" .. vim.env.MYVIMRC or info.what ~= "Lua") do
    level = level + 1
    info = debug.getinfo(level, "S")
  end
  info = info or me
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source) or source
  return source .. ":" .. info.linedefined
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
function M.lsp_keymaps(bufnr)
  local function opts(desc)
    return { buffer = bufnr, noremap = true, silent = true, desc = desc or "" }
  end
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto definition"))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("LSP References"))
  vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts("Workspace Symbols"))
  vim.keymap.set("n", "<leader>cf", function() require("conform").format() end, opts("Format"))
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
  vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts("Rename Symbol"))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("Goto Next Diagnostic"))
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("Goto Prev Diagnostic"))
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts())
  vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float, opts())
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts())
end

return M
