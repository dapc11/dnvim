-- terminal-bg.lua: Detect the terminal background colour and derive a surface
-- palette from it.
--
-- Detection order:
--   1. `vim.g.terminal_bg` - manual pin, e.g. "#1e1e2e"; `false` disables
--   2. OSC 11 query - authoritative, but tmux < 3.3 never forwards it
--   3. The terminal emulator's own configuration
--
-- Everything is asynchronous. The reply to an OSC 11 query arrives on Nvim's
-- own input stream, so it can only be read through |TermResponse| - a
-- subprocess reading /dev/tty competes with the TUI and loses.

local M = {}

local function hex(r, g, b)
  local function clamp(v)
    return math.max(0, math.min(255, math.floor(v + 0.5)))
  end
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

--- Derive the surface palette from a background colour, RGB 0-255.
function M.derive(r, g, b)
  local lum = 0.299 * r + 0.587 * g + 0.114 * b
  local dark = lum < 128

  -- Mix `t` (0-1) of `target` (0 = black, 255 = white) into the background.
  -- Proportional mixing keeps every step perceptible on any background; a
  -- fixed RGB offset is invisible once the background is a mid tone, which is
  -- what made CursorLine, QuickFixLine and fzf-lua's `bg+` look unhighlighted.
  local function mix(target, t)
    return hex(r + (target - r) * t, g + (target - g) * t, b + (target - b) * t)
  end

  -- Raised surfaces move towards the foreground, recessed ones away from it.
  local raise = dark and 255 or 0
  local recede = dark and 0 or 255

  -- Room left in the recessed direction. A near black (or near white)
  -- background has none, so nudge those surfaces the other way instead, by
  -- less than surface0, to keep the layering order intact.
  local headroom = dark and lum or (255 - lum)
  local function recessed(t, fallback)
    if headroom < 32 then
      return mix(raise, fallback)
    end
    return mix(recede, t)
  end

  return {
    normal_bg = "NONE",
    bg = hex(r, g, b),
    darkbg = recessed(0.13, 0.045),
    darker = recessed(0.25, 0.02),
    surface0 = mix(raise, 0.09),
    surface1 = mix(raise, 0.17),
    surface2 = mix(raise, 0.25),
  }
end

--- Parse a colour spec into r, g, b (0-255). Returns nil if there is none.
local function parse_color(spec)
  if type(spec) ~= "string" then
    return nil
  end
  -- rgb:RR[RR]/GG[GG]/BB[BB] - keep the most significant byte of each channel
  local r, g, b = spec:match("rgb:(%x%x)%x*/(%x%x)%x*/(%x%x)%x*")
  if not r then
    r, g, b = spec:match("#(%x%x)(%x%x)(%x%x)")
  end
  if not r then
    return nil
  end
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

--- Ask the terminal for its background colour. OSC 11 replies arrive as a
--- TermResponse event; give up after `timeout` ms.
local function query_osc11(timeout, cb)
  if #vim.api.nvim_list_uis() == 0 then
    return cb(nil)
  end

  local answered = false
  local group = vim.api.nvim_create_augroup("TerminalBgQuery", { clear = true })
  vim.api.nvim_create_autocmd("TermResponse", {
    group = group,
    callback = function(ev)
      local sequence = ev.data and ev.data.sequence or ""
      if answered or not sequence:match("^\27%]11;") then
        return
      end
      answered = true
      cb(sequence)
    end,
  })

  vim.api.nvim_ui_send("\27]11;?\27\\")

  vim.defer_fn(function()
    pcall(vim.api.nvim_del_augroup_by_id, group)
    if not answered then
      cb(nil)
    end
  end, timeout)
end

--- Command name and parent pid of `pid`, from /proc.
local function proc(pid)
  local stat = io.open("/proc/" .. pid .. "/stat", "r")
  if not stat then
    return nil
  end
  local line = stat:read("l") or ""
  stat:close()
  -- "<pid> (<comm>) <state> <ppid> ..." - comm may contain spaces and parens
  local comm, ppid = line:match("^%d+%s+%((.*)%)%s+%S+%s+(%d+)")
  return comm, tonumber(ppid)
end

-- Emulators that have to be asked about their configuration, keyed by the
-- (15 character truncated) name /proc reports. Everything else answers OSC 11.
local EMULATORS = {
  ["gnome-terminal"] = "gnome",
  ["xterm"] = "xrdb",
  ["uxterm"] = "xrdb",
  ["rxvt"] = "xrdb",
}

--- Walk up the process tree until a known terminal emulator shows up.
local function classify(pid)
  for _ = 1, 16 do
    local comm, ppid = proc(pid)
    if not comm then
      return nil
    end
    for name, kind in pairs(EMULATORS) do
      if comm:find(name, 1, true) then
        return kind
      end
    end
    if not ppid or ppid <= 1 then
      return nil
    end
    pid = ppid
  end
end

--- Which emulator is displaying this Nvim? Async, because under tmux the
--- process tree ends at the server and only tmux knows about the client.
local function emulator(cb)
  if not vim.env.TMUX then
    return cb(classify(vim.uv.os_getpid()))
  end
  vim.system({ "tmux", "display-message", "-p", "#{client_pid}" }, { text = true }, function(out)
    local pid = tonumber((out.stdout or ""):match("%d+"))
    cb(pid and classify(pid) or nil)
  end)
end

local GNOME_PROFILE = "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:%s/"

--- Background of the default gnome-terminal profile. A window may well be
--- using another profile, but that is not discoverable from inside tmux.
local function gnome_bg(cb)
  vim.system({ "gsettings", "get", "org.gnome.Terminal.ProfilesList", "default" }, { text = true }, function(out)
    local profile = (out.stdout or ""):match("[%w-]+")
    if not profile then
      return cb(nil)
    end
    local schema = GNOME_PROFILE:format(profile)
    vim.system({ "gsettings", "get", schema, "use-theme-colors" }, { text = true }, function(theme)
      -- With theme colours the GTK theme decides, and that is not readable here.
      if (theme.stdout or ""):match("true") then
        return cb(nil)
      end
      vim.system({ "gsettings", "get", schema, "background-color" }, { text = true }, function(bg)
        cb(bg.stdout)
      end)
    end)
  end)
end

--- Background from the X resource database, for xterm and friends.
local function xrdb_bg(cb)
  vim.system({ "xrdb", "-query" }, { text = true }, function(out)
    for line in (out.stdout or ""):gmatch("[^\n]+") do
      if line:match("^%S*%*background:") then
        return cb(line)
      end
    end
    cb(nil)
  end)
end

local CONFIGURED_BG = { gnome = gnome_bg, xrdb = xrdb_bg }

local function configured_bg(cb)
  emulator(function(kind)
    local lookup = kind and CONFIGURED_BG[kind]
    if not lookup then
      return cb(nil)
    end
    lookup(cb)
  end)
end

--- Resolve the terminal background and pass the derived palette to `cb`, or
--- nil if it could not be determined. Called once, on the main loop.
function M.detect(cb)
  local function finish(spec)
    local r, g, b = parse_color(spec)
    vim.schedule(function()
      cb(r and M.derive(r, g, b) or nil)
    end)
  end

  if vim.g.terminal_bg == false then
    return finish(nil)
  end
  if parse_color(vim.g.terminal_bg) then
    return finish(vim.g.terminal_bg)
  end

  query_osc11(100, function(sequence)
    if parse_color(sequence) then
      return finish(sequence)
    end
    configured_bg(finish)
  end)
end

return M
