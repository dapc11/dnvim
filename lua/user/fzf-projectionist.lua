local storage = vim.fn.stdpath("data") .. "/projectionist_history.json"

local function read_json(path)
  local file = io.open(path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    return ok and data or {}
  end
  return {}
end

local function write_json(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = io.open(path, "w")
  if file then
    file:write(vim.json.encode(data))
    file:close()
  end
end

local function update_history(project)
  local history = read_json(storage)
  local normalized = vim.fn.fnamemodify(project, ":p"):gsub("/$", "")

  for i = #history, 1, -1 do
    if history[i] == normalized then
      table.remove(history, i)
    end
  end
  table.insert(history, 1, normalized)

  if #history > 20 then
    history[21] = nil
  end
  write_json(storage, history)
end

local search_paths = {
  "~/repos",
  "~/repos_personal",
}

local function get_projects()
  local handles = {}
  for _, path in ipairs(search_paths) do
    table.insert(handles, vim.system({ "fd", ".git$", "--prune", "-utd", "--max-depth", "3", vim.fn.expand(path) }, { text = true }))
  end
  local results, seen = {}, {}
  for _, handle in ipairs(handles) do
    local obj = handle:wait()
    if obj.code == 0 then
      for line in obj.stdout:gmatch("[^\n]+") do
        local project = line:gsub("/.git/?$", "")
        if not seen[project] then
          seen[project] = true
          table.insert(results, project)
        end
      end
    end
  end
  return results
end

return function()
  local fzf = require("fzf-lua")
  local recent_files = require("user.fzf-recent-files")

  local cwd = vim.fn.getcwd()

  local history = vim.tbl_filter(function(p)
    return vim.fn.isdirectory(p) == 1 and p ~= cwd
  end, read_json(storage))
  local all_projects = get_projects()

  local recent_set = {}
  for _, p in ipairs(history) do
    recent_set[p] = true
  end

  local projects = {}
  for _, p in ipairs(history) do
    table.insert(projects, "\27[1m" .. p .. "\27[0m")
  end
  for _, project in ipairs(all_projects) do
    if not recent_set[project] and project ~= cwd then
      table.insert(projects, project)
    end
  end

  local function strip_ansi(s)
    return s:gsub("\27%[[%d;]*m", "")
  end

  fzf.fzf_exec(projects, {
    prompt = "Projects> ",
    fzf_opts = { ["--ansi"] = "" },
    winopts = { title = "Projects", title_pos = "center" },
    actions = {
      ["default"] = function(selected)
        if #selected > 0 then
          local path = strip_ansi(selected[1])
          update_history(path)
          fzf.files({ cwd = path })
        end
      end,
      ["ctrl-f"] = function(selected)
        if #selected > 0 then
          local path = strip_ansi(selected[1])
          update_history(path)
          fzf.grep_project({ cwd = path })
        end
      end,
      ["ctrl-r"] = function(selected)
        if #selected > 0 then
          local path = strip_ansi(selected[1])
          update_history(path)
          recent_files({ cwd = path })
        end
      end,
    },
  })
end
