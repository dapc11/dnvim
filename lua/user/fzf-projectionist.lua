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

return function()
  local fzf = require("fzf-lua")
  local recent_files = require("user.fzf-recent-files")

  local history = vim.tbl_filter(function(p)
    return vim.fn.isdirectory(p) == 1
  end, read_json(storage))
  local all_projects = vim.fn.systemlist("fd '.git$' --prune -utd ~/repos ~/repos_personal | xargs dirname")

  local recent_set = {}
  for _, p in ipairs(history) do
    recent_set[p] = true
  end

  local projects = vim.list_extend({}, history)
  for _, project in ipairs(all_projects) do
    if not recent_set[project] then
      table.insert(projects, project)
    end
  end

  fzf.fzf_exec(projects, {
    prompt = "Projects> ",
    winopts = { title = "Projects", title_pos = "center" },
    actions = {
      ["default"] = function(selected)
        if #selected > 0 then
          update_history(selected[1])
          fzf.files({ cwd = selected[1] })
        end
      end,
      ["ctrl-f"] = function(selected)
        if #selected > 0 then
          update_history(selected[1])
          fzf.grep_project({ cwd = selected[1] })
        end
      end,
      ["ctrl-r"] = function(selected)
        if #selected > 0 then
          update_history(selected[1])
          recent_files({ cwd = selected[1] })
        end
      end,
    },
  })
end
