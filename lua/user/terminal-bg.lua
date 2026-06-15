-- terminal-bg.lua: Detect terminal background color and derive surface palette.

local M = {}

local function hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

--- Derive surface palette from RGB (0-255)
function M.derive(r, g, b)
  local lum = 0.299 * r + 0.587 * g + 0.114 * b
  local dark = lum < 128
  local function s(amount)
    if dark then
      return hex(math.min(255, r + amount), math.min(255, g + amount), math.min(255, b + amount))
    else
      return hex(math.max(0, r - amount), math.max(0, g - amount), math.max(0, b - amount))
    end
  end
  return {
    normal_bg = "NONE",
    bg = hex(r, g, b),
    darkbg = s(-6),
    darker = s(-10),
    surface0 = s(4),
    surface1 = s(10),
    surface2 = s(18),
  }
end

--- Synchronously query terminal background. Returns override table or nil.
function M.get()
  local cmd = [[printf '\033]11;?\033\\' > /dev/tty; read -t 0.1 -s resp < /dev/tty; printf '%s' "$resp"]]
  local result = vim.fn.system({ "bash", "-c", cmd })
  if not result or result == "" then return nil end

  local r, g, b = result:match("11;rgb:(%x%x)%x*/(%x%x)%x*/(%x%x)%x*")
  if not r then return nil end

  return M.derive(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

return M
