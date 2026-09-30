---Goto-definition and find-usages for Helm charts.
---
---Helm has no language server, but its cross references are mechanical:
---  * a named template is introduced by `define "x"` and read by
---    `include "x"` / `template "x"`, which rg can index exactly;
---  * `.Values.a.b` resolves to a key in values.yaml and `.Chart.Name` to a
---    key in Chart.yaml, which yq can locate by line.
local M = {}

-- The three keywords that can carry a template name.
local TEMPLATE_REFERENCE = '(%a+)%s+"([^"]+)"'
local KINDS = { define = true, include = true, template = true }

-- Chart metadata reaches templates under Go field names, which differ from the
-- Chart.yaml keys by more than a capital letter in these cases.
local CHART_FIELDS = { apiVersion = "APIVersion", appVersion = "AppVersion", kubeVersion = "KubeVersion" }

-- Helm's render-time objects. Nothing in the chart defines them, so the only
-- direction that exists for these is outward, to the places that read them.
-- Ordered rather than a set, to keep tie-breaking deterministic.
local BUILTINS = { "Release", "Capabilities", "Template", "Files", "Subcharts" }

---Escape text for use inside a Rust regex.
---
---Template names and value paths are dotted, and an unescaped dot would match
---any character and pull in unrelated results.
---@param text string
---@return string escaped
local function escape_regex(text)
  return (text:gsub("[\\%^%$%.%|%?%*%+%(%)%[%]{}]", "\\%0"))
end

---Locate the chart the current buffer belongs to.
---@return string|nil root directory containing Chart.yaml
local function chart_root()
  return require("util").get_project_root("Chart.yaml")
end

---Split the tail of a `.Values...` reference into path segments.
---@param tail string such as ".image.repository"
---@return string[]
local function split_path(tail)
  local segments = {}
  for segment in tail:gmatch("[%w_]+") do
    segments[#segments + 1] = segment
  end
  return segments
end

---Collect every navigable reference on a line, with the span it occupies.
---@param line string
---@return table[] targets
local function scan(line)
  local targets = {}

  local index = 1
  while true do
    local from, to, kind, name = line:find(TEMPLATE_REFERENCE, index)
    if not from then
      break
    end
    if KINDS[kind] then
      targets[#targets + 1] = { from = from, to = to, kind = kind, name = name }
    end
    index = to + 1
  end

  index = 1
  while true do
    local from, to, tail = line:find("%.Values([%.%w_]*)", index)
    if not from then
      break
    end
    targets[#targets + 1] = { from = from, to = to, kind = "values", path = split_path(tail) }
    index = to + 1
  end

  index = 1
  while true do
    local from, to, field = line:find("%.Chart%.(%w+)", index)
    if not from then
      break
    end
    targets[#targets + 1] = { from = from, to = to, kind = "chart", field = field }
    index = to + 1
  end

  -- Helm built-ins such as .Release.Namespace or .Capabilities.KubeVersion.
  for _, object in ipairs(BUILTINS) do
    index = 1
    while true do
      local from, to, tail = line:find("%." .. object .. "([%.%w_]*)", index)
      if not from then
        break
      end
      -- Require a boundary after the object name so .ReleaseFoo is not read as
      -- .Release with a member called Foo.
      if tail == "" or tail:sub(1, 1) == "." then
        targets[#targets + 1] = { from = from, to = to, kind = "builtin", object = object, path = split_path(tail) }
      end
      index = to + 1
    end
  end

  -- Template variables, optionally dereferenced: $global.security.tls.enabled.
  -- Requiring a letter after $ keeps this from swallowing `$.Values.x` or the
  -- bare `$` root, both of which the matchers above already handle.
  index = 1
  while true do
    local from, to, name, tail = line:find("%$([%a_][%w_]*)([%.%w_]*)", index)
    if not from then
      break
    end
    targets[#targets + 1] = { from = from, to = to, kind = "variable", name = name, path = split_path(tail) }
    index = to + 1
  end

  return targets
end

---Find the reference under, or nearest to, the cursor.
---
---One line can hold several, as in
---`{{- default .Chart.Name .Values.nameOverride -}}`, so a reference
---containing the cursor wins outright and proximity decides otherwise.
---@return table|nil target
function M.target_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local nearest, nearest_distance

  for _, target in ipairs(scan(line)) do
    if col >= target.from and col <= target.to then
      return target
    end
    local distance = col < target.from and target.from - col or col - target.to
    if not nearest_distance or distance < nearest_distance then
      nearest, nearest_distance = target, distance
    end
  end
  return nearest
end

---Run rg and return its --vimgrep lines.
---@param pattern string Rust regex
---@param dir string
---@return string[]|nil lines nil only when rg itself failed
local function search(pattern, dir)
  local result = vim
    .system({ "rg", "--vimgrep", "--color=never", "--no-heading", "-e", pattern, "--", dir }, { text = true })
    :wait()

  -- rg exits 1 to mean "no matches", which is an answer rather than a failure.
  if result.code > 1 then
    vim.notify("rg failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return nil
  end

  local lines = {}
  for line in (result.stdout or ""):gmatch("[^\n]+") do
    lines[#lines + 1] = line
  end
  return lines
end

---@param file string
---@param lnum integer
---@param col integer|nil
local function goto_position(file, lnum, col)
  -- Leave a jumplist mark so <C-o> returns, as after a real goto-definition.
  vim.cmd("normal! m'")
  if vim.fn.fnamemodify(file, ":p") ~= vim.fn.expand("%:p") then
    vim.cmd("edit " .. vim.fn.fnameescape(file))
  end
  vim.api.nvim_win_set_cursor(0, { lnum, (col or 1) - 1 })
  vim.cmd("normal! zz")
end

---@param entry string an rg --vimgrep line
local function jump(entry)
  local file, lnum, col = entry:match("^(.-):(%d+):(%d+):")
  if not file then
    vim.notify("Could not parse rg result: " .. entry, vim.log.levels.ERROR)
    return
  end
  goto_position(file, tonumber(lnum), tonumber(col))
end

---Hand the pattern to fzf-lua's grep so results get its previewer, its
---quickfix action and the user's own rg configuration.
local function pick(pattern, dir, title)
  require("fzf-lua").grep({
    regex = pattern, -- alias for search + no_esc, so pattern stays a raw regex
    cwd = dir,
    prompt = title .. "> ",
    winopts = { title = title, title_pos = "center" },
  })
end

---Jump when there is one match, otherwise open a picker.
local function resolve(pattern, root, title)
  local results = search(pattern, root)
  if not results then
    return
  end

  local dir = root
  if #results == 0 then
    -- A define can live in a parent chart or a sibling library chart, so widen
    -- the search once before giving up.
    local cwd = vim.fn.getcwd()
    if cwd ~= root then
      results, dir = search(pattern, cwd) or {}, cwd
    end
  end

  if #results == 0 then
    vim.notify(title .. ": no matches", vim.log.levels.WARN)
  elseif #results == 1 then
    jump(results[1])
  else
    pick(pattern, dir, string.format("%s (%d)", title, #results))
  end
end

---Read a YAML file, preferring a loaded buffer so unsaved edits still resolve.
---@param file string
---@return string[]|nil
local function read_lines(file)
  local bufnr = vim.fn.bufnr(file)
  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end
  if vim.fn.filereadable(file) == 0 then
    vim.notify("Not readable: " .. file, vim.log.levels.WARN)
    return nil
  end
  return vim.fn.readfile(file)
end

---Index every mapping key in a YAML file by walking indentation.
---
---yq is not usable for this: it reports node line numbers shifted by the
---number of comment lines above them, which in a values.yaml full of
---documentation puts every key several lines off. The text is the only
---trustworthy source of positions.
---
---Block mappings are all this needs to handle, because a list index cannot be
---reached through Go template dot access anyway.
---@param lines string[]
---@return table[] entries { path = string[], line = integer, commented = boolean }
local function index_keys(lines)
  local entries, stack = {}, {}
  local block_indent -- indent of a |/> key whose body must not be parsed

  for lnum, text in ipairs(lines) do
    local leading = text:match("^(%s*)") or ""
    local blank = not text:match("%S")
    local inside_block = block_indent and not blank and #leading > block_indent

    if not inside_block then
      block_indent = nil
      local indent, key = text:match("^(%s*)([^%s#][^:]*):")
      local commented = false

      -- Values files document optional settings as commented-out keys, which
      -- are worth navigating too. What separates them from prose is the absence
      -- of a space after the #: `#dataCenters:` is a key, while
      -- `# The list of data centers...` and `# Allowed values: "otlp"` are not.
      if not key then
        indent, key = text:match("^(%s*)#([^%s#%-][^:]*):")
        commented = key ~= nil
      end

      -- Blank lines and list items carry no addressable key.
      local skippable = blank or text:match("^%s*%-")

      if key and not skippable then
        local depth = #indent
        while #stack > 0 and stack[#stack].indent >= depth do
          table.remove(stack)
        end
        stack[#stack + 1] = { indent = depth, key = (key:gsub("^%s*[\"']?", ""):gsub("[\"']?%s*$", "")) }

        local path = {}
        for _, frame in ipairs(stack) do
          path[#path + 1] = frame.key
        end
        entries[#entries + 1] = { path = path, line = lnum, commented = commented }

        if text:match(":%s*[|>][%-+%d]*%s*$") then
          block_indent = depth
        end
      end
    end
  end
  return entries
end

---Find the line of the deepest entry whose path is a prefix of `wanted`.
---
---Charts routinely read values that the chart's own values.yaml does not set,
---such as subchart or global keys, so landing on the closest ancestor beats
---refusing to move.
---@param entries table[]
---@param wanted string[]
---@param ignore_case boolean|nil
---@return table|nil entry, integer depth
local function deepest_match(entries, wanted, ignore_case)
  local best, depth
  for _, entry in ipairs(entries) do
    if #entry.path <= #wanted then
      local matches = true
      for i, segment in ipairs(entry.path) do
        local found, want = tostring(segment), wanted[i]
        if ignore_case then
          found, want = found:lower(), want:lower()
        end
        if found ~= want then
          matches = false
          break
        end
      end
      if matches then
        -- A key that is actually set beats a commented-out one at equal depth.
        local deeper = not depth or #entry.path > depth
        local realer = depth and #entry.path == depth and best and best.commented and not entry.commented
        if deeper or realer then
          best, depth = entry, #entry.path
        end
      end
    end
  end
  return best, depth or 0
end

---Build the rg pattern for reads of a values path.
---
---Two shapes have to be covered. Dot access cannot express a key containing a
---hyphen, because that is not a valid Go template field name, so charts reach
---those through `index $.Values "a" "b"` instead. Resource names such as
---`cassandra-configure-keyspaces` make this common rather than exotic.
---@param path string[]
---@return string|nil pattern
local function values_pattern(path)
  local segments = {}
  for _, segment in ipairs(path) do
    -- A numeric segment is a list index, which neither form addresses by name.
    if tonumber(segment) then
      break
    end
    segments[#segments + 1] = tostring(segment)
  end
  if #segments == 0 then
    return nil
  end

  local dot_safe = true
  local dotted, quoted = {}, {}
  for _, segment in ipairs(segments) do
    if not segment:match("^[%a_][%w_]*$") then
      dot_safe = false
    end
    dotted[#dotted + 1] = escape_regex(segment)
    quoted[#quoted + 1] = '"' .. escape_regex(segment) .. '"'
  end

  local index_form = "index\\s+\\$?\\.Values\\s+" .. table.concat(quoted, "\\s+")
  if not dot_safe then
    return index_form
  end
  -- The trailing \b stops `.Values.image` from also matching
  -- `.Values.imageCredentials`, while still matching `.Values.image.repository`.
  return "(?:\\.Values\\." .. table.concat(dotted, "\\.") .. "\\b|" .. index_form .. ")"
end

---@param key string a Chart.yaml key
---@return string pattern
local function chart_pattern(key)
  local field = CHART_FIELDS[key] or (key:sub(1, 1):upper() .. key:sub(2))
  return "\\.Chart\\." .. escape_regex(field) .. "\\b"
end

---Search for reads of a Helm built-in.
---
---These are supplied by Helm at render time, so there is no definition to jump
---to and every entry point can only list the places that read them.
---@param root string
---@param target table
local function resolve_builtin(root, target)
  local pattern = "\\." .. target.object
  local label = "." .. target.object
  if #target.path > 0 then
    local segments = {}
    for _, segment in ipairs(target.path) do
      segments[#segments + 1] = escape_regex(segment)
    end
    pattern = pattern .. "\\." .. table.concat(segments, "\\.")
    label = label .. "." .. table.concat(target.path, ".")
  end
  resolve(pattern .. "\\b", root, "reads of " .. label .. " (Helm built-in)")
end

---@param root string
---@param path string[]
local function goto_values(root, path)
  local file = root .. "/values.yaml"
  local lines = read_lines(file)
  if not lines then
    return
  end
  if #path == 0 then
    goto_position(file, 1, 1)
    return
  end

  local entry, depth = deepest_match(index_keys(lines), path)
  local wanted = table.concat(path, ".")
  if not entry then
    vim.notify(".Values." .. wanted .. " is not set in values.yaml", vim.log.levels.WARN)
    return
  end
  goto_position(file, entry.line, 1)

  if depth < #path then
    vim.notify(
      string.format(".Values.%s is not in values.yaml; stopped at .%s", wanted, table.concat(path, ".", 1, depth)),
      vim.log.levels.WARN
    )
  elseif entry.commented then
    vim.notify(".Values." .. wanted .. " is commented out in values.yaml", vim.log.levels.WARN)
  end
end

---@param root string
---@param field string a Go field name such as "Name" or "AppVersion"
local function goto_chart(root, field)
  local file = root .. "/Chart.yaml"
  local lines = read_lines(file)
  if not lines then
    return
  end
  -- Chart.yaml keys are lower camel case while templates use Go field names,
  -- so compare without case.
  local entry = deepest_match(index_keys(lines), { field }, true)
  if not entry then
    vim.notify(".Chart." .. field .. " is not set in Chart.yaml", vim.log.levels.WARN)
    return
  end
  goto_position(file, entry.line, 1)
  if entry.commented then
    vim.notify(".Chart." .. field .. " is commented out in Chart.yaml", vim.log.levels.WARN)
  end
end

---Locate the assignment of a template variable.
---
---A Go template variable is scoped to the `define` that assigns it, and charts
---reuse names like $global in every block, so the nearest assignment at or
---above the cursor is the correct one.
---@param name string without the leading $
---@return integer|nil line, string|nil rhs
local function find_assignment(name)
  local pattern = "%$" .. name .. "%s*:?=%s*(.*)"
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for lnum = math.min(cursor, #lines), 1, -1 do
    local rhs = lines[lnum]:match(pattern)
    if rhs then
      return lnum, rhs
    end
  end
  return nil, nil
end

---Follow a `$var.a.b` reference.
---@param root string
---@param target table
local function goto_variable(root, target)
  local lnum, rhs = find_assignment(target.name)
  if not lnum then
    return resolve("\\$" .. escape_regex(target.name) .. "\\s*:?=", root, "$" .. target.name .. " assignment")
  end

  -- When the variable is bound straight to values, the member path can be
  -- rewritten onto it and followed into values.yaml.
  local base = rhs:match("^%$?(%.Values[%.%w_]*)")
  if base then
    local path = split_path((base:gsub("^%.Values", "")))
    for _, segment in ipairs(target.path) do
      path[#path + 1] = segment
    end
    if #path > 0 then
      return goto_values(root, path)
    end
  end

  -- Otherwise it holds something not statically followable, such as a dict a
  -- named template fills in or a positional argument, so the declaration is
  -- the useful destination.
  goto_position(vim.api.nvim_buf_get_name(0), lnum, 1)
end

---Path of the key on the current line of a YAML file.
---@param file string
---@return string[]|nil
local function path_at_cursor(file)
  local lines = read_lines(file)
  if not lines then
    return nil
  end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  for _, entry in ipairs(index_keys(lines)) do
    if entry.line == lnum then
      return entry.path
    end
  end
  vim.notify("No YAML key on this line", vim.log.levels.WARN)
  return nil
end

---@return string|nil root, table|nil target, string filename
local function context()
  local root = chart_root()
  if not root then
    vim.notify("Not inside a Helm chart (no Chart.yaml found)", vim.log.levels.WARN)
    return nil, nil, ""
  end
  return root, M.target_at_cursor(), vim.fn.expand("%:t")
end

---Jump to whatever the reference under the cursor is defined by.
function M.definition()
  local root, target = context()
  if not root then
    return
  end
  if not target then
    vim.notify("Nothing navigable under the cursor", vim.log.levels.WARN)
    return
  end

  if target.kind == "values" then
    return goto_values(root, target.path)
  end
  if target.kind == "chart" then
    return goto_chart(root, target.field)
  end
  if target.kind == "variable" then
    return goto_variable(root, target)
  end
  if target.kind == "builtin" then
    return resolve_builtin(root, target)
  end
  local pattern = 'define\\s+"' .. escape_regex(target.name) .. '"'
  resolve(pattern, root, "define " .. target.name)
end

---@param field string
---@return string with a lower-case first letter
local function lower_first(field)
  return field:sub(1, 1):lower() .. field:sub(2)
end

---List everything that reads the reference under the cursor.
---
---Inside values.yaml or Chart.yaml the key *is* the definition, so the only
---useful direction is outward into the templates.
function M.usages()
  local root, target, filename = context()
  if not root then
    return
  end

  if target and KINDS[target.kind] then
    local pattern = '(?:include|template)\\s+"' .. escape_regex(target.name) .. '"'
    return resolve(pattern, root, "usages of " .. target.name)
  end

  if target and target.kind == "chart" then
    return resolve(chart_pattern(lower_first(target.field)), root, ".Chart." .. target.field)
  end

  if target and target.kind == "builtin" then
    return resolve_builtin(root, target)
  end

  if target and target.kind == "variable" then
    local label, pattern = "$" .. target.name, "\\$" .. escape_regex(target.name)
    if #target.path > 0 then
      local segments = {}
      for _, segment in ipairs(target.path) do
        segments[#segments + 1] = escape_regex(segment)
      end
      label = label .. "." .. table.concat(target.path, ".")
      pattern = pattern .. "\\." .. table.concat(segments, "\\.")
    end
    return resolve(pattern .. "\\b", root, "reads of " .. label)
  end
  if not target and filename == "Chart.yaml" then
    local path = path_at_cursor(root .. "/Chart.yaml")
    if not path then
      return
    end
    -- Only top-level Chart.yaml keys surface as .Chart fields; anything nested
    -- is reached through the field that contains it.
    local key = path[1]
    return resolve(chart_pattern(key), root, ".Chart." .. key)
  end

  local path = target and target.kind == "values" and #target.path > 0 and target.path or nil
  if not path and filename == "values.yaml" then
    path = path_at_cursor(root .. "/values.yaml")
  end
  if not path then
    vim.notify("Nothing navigable under the cursor", vim.log.levels.WARN)
    return
  end
  local pattern = values_pattern(path)
  if not pattern then
    vim.notify("No dot-accessible values path here", vim.log.levels.WARN)
    return
  end
  resolve(pattern, root, "reads of .Values." .. table.concat(path, "."))
end

---Follow the reference under the cursor in the direction that makes sense:
---outward from a definition to its readers, inward from a reference to what
---defines it.
function M.smart()
  local root, target, filename = context()
  if not root then
    return
  end

  if not target then
    if filename == "values.yaml" or filename == "Chart.yaml" then
      return M.usages()
    end
    vim.notify("Nothing navigable under the cursor", vim.log.levels.WARN)
    return
  end
  if target.kind == "define" then
    return M.usages()
  end
  return M.definition()
end

---Browse every named template defined in the chart.
function M.templates()
  local root = chart_root()
  if not root then
    vim.notify("Not inside a Helm chart (no Chart.yaml found)", vim.log.levels.WARN)
    return
  end
  pick('define\\s+"', root, "Helm templates")
end

---Bind the navigation keys in the current buffer, but only for files that
---belong to a chart.
---
---Chart templates resolve to the `helm` filetype and Chart.yaml/values.yaml to
---`yaml`, so this is called from both ftplugins.
---@param opts { goto_keys: boolean }|nil goto_keys binds gd/grr, which is only
---safe where no language server competes for them
function M.attach(opts)
  opts = opts or {}
  if not chart_root() then
    return
  end

  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = true, silent = true, desc = "Helm: " .. desc })
  end
  map("<leader>hd", M.smart, "Goto definition or usages")
  map("<leader>hu", M.usages, "Find usages")
  map("<leader>ht", M.templates, "Find all templates")

  -- No configured server lists the helm filetype, so nothing overwrites these
  -- on LspAttach the way yamlls would on a yaml buffer. grr rather than gr,
  -- because gr alone is ambiguous with Neovim's grn/gra/gri/grt.
  if opts.goto_keys then
    map("gd", M.smart, "Goto definition or usages")
    map("grr", M.usages, "Find usages")
  end

  vim.api.nvim_buf_create_user_command(0, "HelmDefinition", M.definition, { desc = "Helm: goto definition" })
  vim.api.nvim_buf_create_user_command(0, "HelmUsages", M.usages, { desc = "Helm: find usages" })
  vim.api.nvim_buf_create_user_command(0, "HelmTemplates", M.templates, { desc = "Helm: all templates" })
end

return M
