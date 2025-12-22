local M = {}

-- Core file operations
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

local function read_lines(path)
  local lines = {}
  local file = io.open(path, "r")
  if file then
    for line in file:lines() do
      if line ~= "" then table.insert(lines, line) end
    end
    file:close()
  end
  return lines
end

local function write_lines(path, lines)
  local file = io.open(path, "w")
  if file then
    for _, line in ipairs(lines) do file:write(line .. "\n") end
    file:close()
  end
end

-- Path utilities
local git_cache = {}
local function abbreviate_path(file)
  local home = vim.fn.expand("~")
  local path = file:gsub("^" .. home, "~", 1)

  local dir = vim.fn.fnamemodify(file, ":h")
  local git_root = git_cache[dir]
  if git_root == nil then
    git_root = false
    local check_dir = dir
    while check_dir ~= "/" and check_dir ~= "" do
      if vim.fn.isdirectory(check_dir .. "/.git") == 1 then
        git_root = check_dir
        break
      end
      local parent = vim.fn.fnamemodify(check_dir, ":h")
      if parent == check_dir then break end
      check_dir = parent
    end
    git_cache[dir] = git_root
  end

  if git_root then
    local segments = vim.split(path, "/")
    local repo_name = vim.fn.fnamemodify(git_root, ":t")
    for i = 1, #segments - 2 do
      if segments[i] ~= repo_name then
        segments[i] = segments[i]:sub(1, 1)
      end
    end
    return table.concat(segments, "/")
  end
  return path
end

-- History management
local function update_history(path, item, max_items)
  local items = read_json(path)
  -- Remove existing and add to front
  for i = #items, 1, -1 do
    if items[i] == item then table.remove(items, i) end
  end
  table.insert(items, 1, item)
  -- Trim to max
  while #items > max_items do table.remove(items) end
  write_json(path, items)
end

-- Recent files picker
function M.setup_recent_files()
  local storage = vim.fn.stdpath("data") .. "/recent_files.txt"

  local function track_file(file)
    if not file or file == "" or file:match("^%w+://") then return end
    if vim.bo.buftype ~= "" or vim.tbl_contains({ "help", "qf", "fugitive" }, vim.bo.filetype) then return end
    if vim.fn.fnamemodify(file, ":t") == "COMMIT_EDITMSG" then return end

    file = vim.fn.resolve(vim.fn.fnamemodify(file, ":p"))
    local pos = vim.api.nvim_win_get_cursor(0)
    local entry = string.format("%s:%d:%d", file, pos[1], pos[2] + 1)

    local lines = read_lines(storage)
    local new_lines = { entry }
    local seen = { [file] = true }

    for _, line in ipairs(lines) do
      local existing_file = line:match("^([^:]+)")
      if existing_file and not seen[existing_file] and #new_lines < 200 then
        table.insert(new_lines, line)
        seen[existing_file] = true
      end
    end

    write_lines(storage, new_lines)
  end

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufLeave", "VimLeavePre" }, {
    callback = function() track_file(vim.fn.expand("%:p")) end,
  })

  return function(opts)
    opts = require("fzf-lua.config").normalize_opts(opts, "oldfiles") or {}
    local filter_cwd = opts.cwd and vim.fn.fnamemodify(opts.cwd, ":p"):gsub("/$", "")
    local current_file = vim.fn.expand("%:p")

    local positions = {}
    local files = {}

    for _, line in ipairs(read_lines(storage)) do
      local file = line:match("^([^:]+)")
      if file and vim.fn.filereadable(file) == 1 and file ~= current_file then
        if not filter_cwd or vim.startswith(file, filter_cwd .. "/") then
          positions[file] = line
          table.insert(files, file)
        end
      end
    end

    opts.actions = {
      ["default"] = function(selected)
        if #selected == 0 then return end
        for file, line in pairs(positions) do
          if abbreviate_path(file) == selected[1] then
            local _, _, line_num, col = line:find("^[^:]+:(%d+):(%d+)")
            vim.cmd("edit " .. file)
            vim.api.nvim_win_set_cursor(0, { tonumber(line_num) or 1, (tonumber(col) or 1) - 1 })
            return
          end
        end
      end,
      ["alt-q"] = function(selected)
        local qf_list = {}
        for _, display_path in ipairs(selected) do
          for file, line in pairs(positions) do
            if abbreviate_path(file) == display_path then
              local _, _, line_num, col = line:find("^[^:]+:(%d+):(%d+)")
              table.insert(qf_list, {
                filename = file,
                lnum = tonumber(line_num) or 1,
                col = tonumber(col) or 1,
                text = display_path,
              })
              break
            end
          end
        end
        vim.fn.setqflist(qf_list)
        vim.cmd("copen")
      end,
    }

    return require("fzf-lua.core").fzf_exec(function(cb)
      for _, file in ipairs(files) do
        cb(abbreviate_path(file))
      end
      cb(nil)
    end, opts)
  end
end

-- Projectionist picker
function M.create_projectionist_picker()
  local fzf = require("fzf-lua")
  local storage = vim.fn.stdpath("data") .. "/projectionist_history.json"

  return function()
    local recent = vim.tbl_filter(function(p) return vim.fn.isdirectory(p) == 1 end, read_json(storage))
    local all_projects = vim.fn.systemlist("fd '.git$' --prune -utd ~/repos ~/repos_personal | xargs dirname")

    if vim.v.shell_error ~= 0 then all_projects = {} end

    local recent_set = {}
    for _, p in ipairs(recent) do recent_set[p] = true end

    local projects = vim.list_extend({}, recent)
    for _, project in ipairs(all_projects) do
      if not recent_set[project] then
        table.insert(projects, project)
      end
    end

    fzf.fzf_exec(projects, {
      actions = {
        ["default"] = function(selected)
          if #selected > 0 then
            update_history(storage, selected[1], 20)
            fzf.files({ cwd = selected[1] })
          end
        end,
        ["ctrl-f"] = function(selected)
          if #selected > 0 then
            update_history(storage, selected[1], 20)
            fzf.grep_project({ cwd = selected[1] })
          end
        end,
        ["ctrl-r"] = function(selected)
          if #selected > 0 then
            update_history(storage, selected[1], 20)
            M.setup_recent_files()({ cwd = selected[1] })
          end
        end,
      },
      prompt = "Projects> ",
      winopts = { title = "Projects", title_pos = "center" },
    })
  end
end

return M
