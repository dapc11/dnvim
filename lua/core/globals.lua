local function map_utils(rhs, opts)
  opts = opts or {}
  local callback = nil
  if type(rhs) ~= "string" then
    callback = rhs
  end

  opts = vim.tbl_extend("keep", opts, {
    noremap = true,
    silent = true,
    expr = false,
    callback = callback,
  })
  return rhs, opts
end

function _G.map(mode, lhs, rhs, opts)
  local r, o = map_utils(rhs, opts)
  vim.keymap.set(mode, lhs, r, o)
end

function _G.bmap(bufnr, mode, lhs, rhs, opts)
  local r, o = map_utils(rhs, opts)
  local wk_opts = vim.tbl_extend("keep", o, { buffer = bufnr })
  vim.keymap.set(mode, lhs, r, wk_opts)
end

function _G.au(event, filetype, action)
  vim.cmd("au" .. " " .. event .. " " .. filetype .. " " .. action)
end

function _G.hi_link(group, target)
  vim.cmd("hi! link " .. group .. " " .. target)
end

function _G.hi(group, options)
  vim.cmd(
    "hi "
    .. group
    .. " "
    .. "cterm="
    .. (options.cterm or "none")
    .. " "
    .. "ctermfg="
    .. (options.ctermfg or "none")
    .. " "
    .. "ctermbg="
    .. (options.ctermbg or "none")
    .. " "
    .. "gui="
    .. (options.gui or "none")
    .. " "
    .. "guifg="
    .. (options.guifg or "none")
    .. " "
    .. "guibg="
    .. (options.guibg or "none")
  )
end

function _G.isempty(s)
  return s == nil or s == ""
end

function _G.get_buf_option(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end
