-- Fail-safe against accidental quits in Neovide.
--
-- In a terminal an accidental :q costs one `nvim` invocation, but in Neovide it
-- tears down the whole GUI, so the same slip is expensive. The quit commands
-- are routed through a guard that keeps the session alive unless leaving was
-- clearly deliberate:
--
--   more than one window       :q closes the window          (stock behaviour)
--   last window, real buffer   swaps in the dashboard, session stays up
--   last window, dashboard     asks for confirmation, then quits
--   any ! variant, :Quit       quits straight away, no questions
--
-- This module is only required from config.neovide, so terminal Neovim keeps
-- stock quit behaviour.

local M = {}

---Quit commands worth guarding, keyed by canonical command name.
---`write` is the command used to save first (nil for the discarding variants),
---`all` marks the whole-session variants that never stop at a single window.
local specs = {
  q = {},
  qu = {},
  qui = {},
  quit = {},
  x = { write = "update" },
  xi = { write = "update" },
  xit = { write = "update" },
  exi = { write = "update" },
  exit = { write = "update" },
  wq = { write = "write" },
  qa = { all = true },
  qal = { all = true },
  qall = { all = true },
  quita = { all = true },
  quitall = { all = true },
  xa = { all = true, write = "update" },
  xall = { all = true, write = "update" },
  wqa = { all = true, write = "write" },
  wqall = { all = true, write = "write" },
}

---Abbreviation triggers mapped to the canonical command they stand for. The
---capitalised entries are the shift-slip fixes from config.usercmds: those
---expand straight to :q/:qa/:wq, which would sneak past this guard, so they
---are redefined here to land on the guarded path instead.
local triggers = {
  Q = "q",
  Qa = "qa",
  Qw = "wq",
  WQ = "wq",
  Wq = "wq",
  Wqa = "wqa",
}
for name in pairs(specs) do
  triggers[name] = name
end

---Would closing this window end the session?
local function last_window()
  -- Closing a float never ends the session, and a float must not make the
  -- current window look like one of several either.
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return false
  end
  if #vim.api.nvim_list_tabpages() > 1 then
    return false
  end
  local ordinary = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      ordinary = ordinary + 1
    end
  end
  return ordinary <= 1
end

local function on_dashboard()
  return vim.bo.filetype == "dashboard"
end

local function unsaved_buffers()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" then
      count = count + 1
    end
  end
  return count
end

---Leave for real. Uses :confirm so unwritten buffers still get a prompt.
local function leave(spec, name)
  -- :wq on the dashboard would fail with E32 (no file name); there is nothing
  -- to write in a scratch buffer, so drop the write half of the command.
  if spec.write and vim.bo.buftype ~= "" then
    name = spec.all and "quitall" or "quit"
  end
  vim.cmd("confirm " .. name)
end

local function confirm_leave(spec, name)
  local unsaved = unsaved_buffers()
  local prompt = "Quit Neovide?"
  if unsaved > 0 then
    prompt = ("%s (%d unsaved)"):format(prompt, unsaved)
  end
  if vim.fn.confirm(prompt, "&Quit\n&Cancel", 2, "Question") == 1 then
    leave(spec, name)
  end
end

---Entry point for every guarded quit, from both the command line and keymaps.
---@param arg string canonical quit command, bang included: "q", "wq!", "qa"
function M.quit(arg)
  local name, bang = arg:match("^(%a+)(!?)$")
  local spec = name and specs[name]
  if not spec then
    vim.notify(("GuardedQuit: not a quit command: %s"):format(arg), vim.log.levels.ERROR)
    return
  end

  -- A bang is an explicit "I mean it". It also arrives here rather than staying
  -- on the command line: the "!" of ":q!" is a non-keyword character, so typing
  -- it expands the bare "q" abbreviation first and the line becomes
  -- ":GuardedQuit q!".
  if bang == "!" then
    vim.cmd(name .. "!")
    return
  end

  if not spec.all and not last_window() then
    vim.cmd(name) -- just a window among several: nothing to guard
    return
  end

  -- The dashboard is the end of the road, so quitting from there is taken at
  -- face value: only the confirmation stands between it and exiting.
  if spec.all or on_dashboard() then
    confirm_leave(spec, name)
    return
  end

  if spec.write then
    local ok, err = pcall(vim.cmd, spec.write)
    if not ok then
      -- The write failed, so swapping the buffer out now would hide work the
      -- user just asked to save.
      vim.notify(tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  require("user.dashboard").open()
  vim.notify("Quit guarded - :Quit exits, :b# goes back", vim.log.levels.INFO)
end

---Body of the command-line abbreviations. Returns the text the abbreviation
---expands to: the guarded command when this quit would end the session, and
---the plain command otherwise, so cmdline history stays readable.
---@param lhs string the abbreviation as typed, bang included
---@return string
function M.expand(lhs)
  local base, bang = lhs:match("^(%a+)(!?)$")
  local name = base and triggers[base]
  if not name then
    return lhs
  end

  -- Guarded with the same rule as the abbreviations in config.usercmds: only
  -- fire when the abbreviation is the entire ":" command line. Unguarded, the
  -- rewrite would also hit arguments such as ":e x.txt" or ":CopyCmd q".
  if vim.fn.getcmdtype() ~= ":" or vim.fn.getcmdline() ~= lhs then
    return lhs
  end

  -- A bang is an explicit "I mean it", and the shift-slip fixes still need
  -- their correction applied.
  if bang == "!" then
    return name .. bang
  end
  if not specs[name].all and not last_window() then
    return name
  end
  return "GuardedQuit " .. name
end

vim.api.nvim_create_user_command("GuardedQuit", function(args)
  M.quit(args.args)
end, { nargs = 1, desc = "Quit through the accidental-quit guard" })

vim.api.nvim_create_user_command("Quit", function(args)
  vim.cmd(args.bang and "qall!" or "confirm qall")
end, { bang = true, desc = "Quit Neovide, bypassing the accidental-quit guard" })

for lhs in pairs(triggers) do
  for _, bang in ipairs({ "", "!" }) do
    vim.cmd(
      ("cnoreabbrev <expr> %s%s v:lua.require'user.quit-guard'.expand(%s)"):format(
        lhs,
        bang,
        vim.fn.string(lhs .. bang)
      )
    )
  end
end

local map = require("util").map
map("n", "ZZ", function()
  M.quit("x")
end, { desc = "Write and close window (guarded)" })
map("n", "ZQ", function()
  M.quit("q")
end, { desc = "Close window (guarded)" })
map("n", "<C-w>q", function()
  M.quit("q")
end, { desc = "Close window (guarded)" })

return M
