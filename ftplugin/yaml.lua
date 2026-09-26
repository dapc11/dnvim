local helm = require("util.helm")

---Copy text to the system clipboard and confirm what was copied.
---@param items string[]
---@param separator string
local function copy(items, separator)
  if #items == 0 then
    return
  end
  local text = table.concat(items, separator)
  vim.fn.setreg("+", text)
  vim.notify(#text > 120 and (text:sub(1, 117) .. "...") or text)
end

---Move the cursor to the leaf key of a path.
---
---Searching the parent key first keeps the match accurate when the same leaf
---name appears in several sections. Numeric segments are skipped because an
---array index is not text that exists in the buffer.
---@param path (string|number)[]
local function jump_to(path)
  local names = {}
  for _, segment in ipairs(path) do
    if type(segment) == "string" then
      names[#names + 1] = segment
    end
  end
  if #names == 0 then
    return
  end
  -- \V is very nomagic, so key names containing regex characters such as the
  -- dot in "kubernetes.io/role" are matched literally.
  if #names > 1 then
    vim.fn.search("\\V" .. names[#names - 1])
  end
  vim.fn.search("\\V" .. names[#names])
end

---Read every scalar in the current file as exact path/value pairs.
---@return table[]|nil nodes list of { p = path, v = value }
local function read_yaml_nodes()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("Buffer is not backed by a file on disk", vim.log.levels.WARN)
    return nil
  end

  -- JSON with the raw path array, rather than a pre-joined dotted string,
  -- because joining loses the difference between an array index and a key and
  -- between nesting and a key that literally contains a dot.
  local query = '[.. | select(. == "*") | {"p": path, "v": .}]'
  local result = vim.system({ "yq", "e", "-o=json", "-I=0", query, file }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("yq failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return nil
  end

  local ok, nodes = pcall(vim.json.decode, result.stdout)
  if not ok or type(nodes) ~= "table" then
    vim.notify("Could not parse yq output", vim.log.levels.ERROR)
    return nil
  end
  return nodes
end

local function fzf_yaml()
  local nodes = read_yaml_nodes()
  if not nodes then
    return
  end

  -- Entries are displayed in Helm's own key=value form so that what is shown
  -- is exactly what the copy actions put on the clipboard.
  local entries, lookup = {}, {}
  for _, node in ipairs(nodes) do
    local key = helm.key(node.p)
    local value = helm.value(node.v)
    local line = key .. "=" .. value
    entries[#entries + 1] = line
    lookup[line] = { key = key, value = value, path = node.p }
  end

  ---@param selected string[]
  ---@param field string
  ---@return string[]
  local function collect(selected, field)
    local out = {}
    for _, line in ipairs(selected) do
      local entry = lookup[line]
      if entry then
        out[#out + 1] = field == "flag" and helm.set_flag(entry.key, entry.value) or entry[field]
      end
    end
    return out
  end

  require("fzf-lua").fzf_exec(entries, {
    prompt = "YAML> ",
    -- Building a helm command usually needs several --set flags at once.
    fzf_opts = { ["--multi"] = true },
    actions = {
      ["default"] = function(selected)
        local entry = lookup[selected[1]]
        if entry then
          jump_to(entry.path)
        end
      end,
      ["ctrl-k"] = function(selected)
        copy(collect(selected, "key"), "\n")
      end,
      ["ctrl-v"] = function(selected)
        copy(collect(selected, "value"), "\n")
      end,
      ["ctrl-s"] = function(selected)
        copy(collect(selected, "flag"), " ")
      end,
    },
  })
end

vim.keymap.set("n", "<leader>fk", fzf_yaml, { desc = "Find YAML key", buffer = true })
vim.keymap.set("n", "gj", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })
