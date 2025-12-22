local M = {}

-- Shared utilities
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

local function abbreviate_path(file)
  local home = vim.fn.expand("~")
  local path = file:gsub("^" .. home, "~", 1)

  -- Find git root
  local dir = vim.fn.fnamemodify(file, ":h")
  local git_root
  while dir ~= "/" and dir ~= "" do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      git_root = dir
      break
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end

  local segments = vim.split(path, "/")
  local repo_name = git_root and vim.fn.fnamemodify(git_root, ":t")

  for i = 1, #segments - 2 do
    if segments[i] ~= repo_name then
      segments[i] = segments[i]:sub(1, 1)
    end
  end
  return table.concat(segments, "/")
end

-- Recent files picker
function M.setup_recent_files()
  local storage = vim.fn.stdpath("data") .. "/recent_files.txt"

  local function track_file(file)
    if not file or file == "" or file:match("^%w+://") then return end
    if vim.bo.buftype ~= "" or vim.tbl_contains({ "help", "qf", "fugitive" }, vim.bo.filetype) then return end

    file = vim.fn.resolve(vim.fn.fnamemodify(file, ":p"))
    local pos = vim.api.nvim_win_get_cursor(0)
    local entry = string.format("%s:%d:%d", file, pos[1], pos[2] + 1)

    local lines = {}
    if vim.fn.filereadable(storage) == 1 then
      for line in io.lines(storage) do
        local existing_file = line:match("^([^:]+)")
        if existing_file and existing_file ~= file then
          table.insert(lines, line)
        end
      end
    end

    table.insert(lines, 1, entry)
    if #lines > 200 then lines[201] = nil end

    local file_handle = io.open(storage, "w")
    if file_handle then
      for _, line in ipairs(lines) do file_handle:write(line .. "\n") end
      file_handle:close()
    end
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

    if vim.fn.filereadable(storage) == 1 then
      for line in io.lines(storage) do
        local file = line:match("^([^:]+)")
        if file and vim.fn.filereadable(file) == 1 and file ~= current_file then
          if not filter_cwd or vim.startswith(file, filter_cwd .. "/") then
            positions[file] = line
            table.insert(files, file)
          end
        end
      end
    end

    return require("fzf-lua.core").fzf_exec(function(cb)
      for _, file in ipairs(files) do
        cb(abbreviate_path(file))
      end
      cb(nil)
    end, vim.tbl_extend("force", opts, {
      actions = {
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
      },
    }))
  end
end

-- Projectionist picker
function M.create_projectionist_picker()
  local storage = vim.fn.stdpath("data") .. "/projectionist_history.json"

  local function update_history(project)
    local history = read_json(storage)
    local normalized = vim.fn.fnamemodify(project, ":p"):gsub("/$", "")

    for i = #history, 1, -1 do
      if history[i] == normalized then table.remove(history, i) end
    end
    table.insert(history, 1, normalized)

    if #history > 20 then history[21] = nil end
    write_json(storage, history)
  end

  return function()
    local fzf = require("fzf-lua")
    local history = vim.tbl_filter(function(p) return vim.fn.isdirectory(p) == 1 end, read_json(storage))
    local all_projects = vim.fn.systemlist("fd '.git$' --prune -utd ~/repos ~/repos_personal | xargs dirname")

    local recent_set = {}
    for _, p in ipairs(history) do recent_set[p] = true end

    local projects = vim.list_extend({}, history)
    for _, project in ipairs(all_projects) do
      if not recent_set[project] then table.insert(projects, project) end
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
            M.setup_recent_files()({ cwd = selected[1] })
          end
        end,
      },
    })
  end
end

-- Git search picker
function M.create_git_search_picker()
  local function parse_search_query(query)
    local includes = {}
    local excludes = {}

    for term in query:gmatch("%S+") do
      if term:match("^!") then
        table.insert(excludes, term:sub(2)) -- Remove the !
      else
        table.insert(includes, term)
      end
    end

    return includes, excludes
  end

  local function search_git_history(search_term)
    local includes, excludes = parse_search_query(search_term)

    if #includes == 0 then
      vim.notify("No search terms provided")
      return {}
    end

    -- Build grep command with includes
    local grep_terms = table.concat(vim.tbl_map(vim.fn.shellescape, includes), " ")
    local cmd = string.format("git rev-list --all | xargs -P4 -n100 git grep -n -F %s 2>/dev/null || true", grep_terms)

    vim.notify("Searching git history...")
    local results = vim.fn.systemlist(cmd)

    if #results == 0 then return {} end

    local entries = {}
    for _, line in ipairs(results) do
      if line ~= "" then
        local commit, file, line_num, content = line:match("^([^:]+):([^:]+):(%d+):(.*)$")
        if commit and file and line_num and content then
          -- Apply exclude filters
          local should_exclude = false
          for _, exclude_term in ipairs(excludes) do
            if content:lower():find(exclude_term:lower(), 1, true) then
              should_exclude = true
              break
            end
          end

          if not should_exclude then
            table.insert(entries,
              string.format("%s:%s:%s %s", commit:sub(1, 8), file, line_num, content:gsub("^%s+", "")))
          end
        end
      end
    end

    if #entries > 0 then vim.notify(string.format("Found %d matches", #entries)) end
    return entries
  end

  local function create_git_actions(action)
    return function(selected)
      if #selected == 0 then return end
      local commit, file, line_num = selected[1]:match("^([^:]+):([^:]+):(%d+)")
      if commit and file and line_num then
        vim.cmd(string.format("%s %s:%s", action, commit, file))
        vim.api.nvim_win_set_cursor(0, { tonumber(line_num), 0 })
      end
    end
  end

  return function()
    vim.ui.input({ prompt = "Git Search: " }, function(search_term)
      if not search_term or search_term == "" then return end

      local entries = search_git_history(search_term)
      if #entries == 0 then
        vim.notify("No matches found")
        return
      end

      local fzf = require("fzf-lua")
      fzf.fzf_exec(entries, {
        prompt = string.format("Git Search (%s)> ", search_term),
        winopts = { title = string.format("Git History: %s (%d results)", search_term, #entries), title_pos = "center", preview = { hidden = "nohidden" } },
        fzf_opts = {
          ["--delimiter"] = ":",
          ["--with-nth"] = "1,2,3,4..",
          ["--preview-window"] = vim.o.columns < 120 and "down:50%:+{3}/2" or "right:50%:+{3}/2",
        },
        preview = {
          type = "cmd",
          fn = function(items)
            local commit, file, line_num = items[1]:match("^([^:]+):([^:]+):(%d+)")
            if commit and file and line_num then
              local lang = vim.fn.fnamemodify(file, ":e")
              return string.format(
                "git show %s:%s | bat --style=numbers --highlight-line=%s --language=%s --color=always",
                commit, file, line_num, lang ~= "" and lang or "txt")
            end
            return ""
          end,
        },
        actions = {
          ["default"] = create_git_actions("Gedit"),
          ["ctrl-s"] = create_git_actions("Gsplit"),
          ["ctrl-v"] = create_git_actions("Gvsplit"),
        },
      })
    end)
  end
end

return M
