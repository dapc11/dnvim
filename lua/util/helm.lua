local M = {}

---Format an exact node path as a Helm `--set` key.
---
---Helm's --set parser treats `.` as a path separator and `[n]` as an array
---index, so a dotted string built by `yq ... | join(".")` is ambiguous in two
---ways: `tolerations.0.key` looks like a map key named "0", and
---`nodeSelector.kubernetes.io/role` looks three levels deep when it is really
---two. Working from the path array keeps both cases correct.
---@param path (string|number)[] path segments as returned by `yq`'s path operator
---@return string key Helm --set compatible key
function M.key(path)
  local parts = {}
  for _, segment in ipairs(path) do
    if type(segment) == "number" then
      parts[#parts + 1] = "[" .. segment .. "]"
    else
      -- A literal dot inside a key name has to be escaped or Helm descends
      -- into a nested map instead of matching the key.
      local name = tostring(segment):gsub("%.", "\\.")
      parts[#parts + 1] = (#parts > 0 and "." or "") .. name
    end
  end
  return table.concat(parts)
end

---Format a scalar as a Helm `--set` value.
---@param value string|number|boolean|nil decoded scalar
---@return string value Helm --set compatible value
function M.value(value)
  if value == nil or value == vim.NIL then
    return "null"
  end
  if type(value) == "boolean" or type(value) == "number" then
    return tostring(value)
  end

  -- Backslash has to go first, otherwise it doubles the escapes added below.
  local escaped = tostring(value):gsub("\\", "\\\\")
  -- Helm reads `,` as an assignment separator and `{}` as list syntax.
  escaped = escaped:gsub("([,{}])", "\\%1")
  return escaped
end

-- Characters a shell passes through untouched. Deliberately conservative:
-- backslash is excluded because it carries Helm's escapes, and [] are excluded
-- because they are glob characters that array indices would otherwise expose.
local SHELL_SAFE = "^[%w_@%%+=:,./-]+$"

---Quote an argument so that a shell hands it to Helm unchanged.
---
---Without this, pasting the flag into a shell silently destroys Helm's
---escapes: bash turns `kubernetes\.io` into `kubernetes.io` (wrong nesting)
---and `a\,b` into `a,b` (Helm then fails with `key "b" has no value`).
---@param arg string
---@return string quoted
local function shell_quote(arg)
  if arg:match(SHELL_SAFE) then
    return arg
  end
  -- An embedded single quote has to leave and re-enter the quoted run.
  local escaped = arg:gsub("'", "'\\''")
  return "'" .. escaped .. "'"
end

---Format a key/value pair as a complete, paste-ready `--set` flag.
---@param key string already formatted by M.key
---@param value string already formatted by M.value
---@return string flag
function M.set_flag(key, value)
  return "--set " .. shell_quote(key .. "=" .. value)
end

return M
