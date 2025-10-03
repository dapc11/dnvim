local M = {}

-- Projectionist frequency tracking
local projectionist_history = {}
local file_scores = {} -- New: File scoring system

local function get_projectionist_config()
  local defaults = {
    history_dir = vim.fn.stdpath("data") .. "/fzf-projectionist",
    max_history = 50,
    auto_history = true,
    -- File scoring configuration
    file_scoring = {
      enabled = true,
      max_file_history = 100,
      recency_weight = 0.6, -- How much recent access matters (0-1)
      frequency_weight = 0.4, -- How much frequency matters (0-1)
      time_decay_days = 30, -- Days after which old entries start losing weight
    },
  }

  return vim.tbl_deep_extend("force", defaults, vim.g.fzf_projectionist or {})
end

local function get_projectionist_history_file()
  local config = get_projectionist_config()
  return config.history_dir .. "/history.json"
end

-- File scoring functions
local function get_file_scores_file()
  local config = get_projectionist_config()
  return config.history_dir .. "/file_scores.json"
end

local function save_file_scores()
  local config = get_projectionist_config()

  -- Ensure history directory exists
  if vim.fn.isdirectory(config.history_dir) == 0 then
    vim.fn.mkdir(config.history_dir, "p")
  end

  local file_path = get_file_scores_file()
  local file = io.open(file_path, "w")
  if file then
    file:write(vim.json.encode(file_scores))
    file:close()
  end
end

local function load_file_scores()
  local file_path = get_file_scores_file()
  if vim.fn.filereadable(file_path) == 1 then
    local file = io.open(file_path, "r")
    if file then
      local content = file:read("*a")
      file:close()
      if content and content ~= "" then
        local ok, scores = pcall(vim.json.decode, content)
        if ok and scores then
          file_scores = scores
          return true
        end
      end
    end
  end
  file_scores = {}
  return false
end

local function calculate_file_score(file_entry, config)
  local now = os.time()
  local recency_weight = config.file_scoring.recency_weight
  local frequency_weight = config.file_scoring.frequency_weight
  local time_decay_days = config.file_scoring.time_decay_days

  -- Calculate recency score (0-1, where 1 is most recent)
  local time_diff = now - file_entry.last_accessed
  local days_old = time_diff / (24 * 60 * 60)
  local recency_score = math.max(0, 1 - (days_old / time_decay_days))

  -- Calculate frequency score (normalized by access count)
  local frequency_score = math.min(1, file_entry.access_count / 10) -- Cap at 10 accesses for normalization

  -- Combine scores
  return (recency_score * recency_weight) + (frequency_score * frequency_weight)
end

local function add_file_access(project_path, file_path)
  local config = get_projectionist_config()

  if not config.file_scoring.enabled then
    return
  end

  -- Load file scores if not already loaded
  if not file_scores or vim.tbl_isempty(file_scores) then
    load_file_scores()
  end

  -- Normalize paths
  local normalized_project = vim.fn.fnamemodify(project_path, ":p"):gsub("/$", "")
  local normalized_file = vim.fn.fnamemodify(file_path, ":p")

  -- Initialize project entry if it doesn't exist
  if not file_scores[normalized_project] then
    file_scores[normalized_project] = {}
  end

  local project_files = file_scores[normalized_project]

  -- Update or create file entry
  if project_files[normalized_file] then
    project_files[normalized_file].access_count = project_files[normalized_file].access_count + 1
    project_files[normalized_file].last_accessed = os.time()
  else
    project_files[normalized_file] = {
      access_count = 1,
      last_accessed = os.time(),
      first_accessed = os.time(),
    }
  end

  -- Clean up old entries if we exceed max_file_history
  local file_list = {}
  for file, entry in pairs(project_files) do
    table.insert(file_list, { file = file, entry = entry })
  end

  if #file_list > config.file_scoring.max_file_history then
    -- Sort by score and keep only the top entries
    table.sort(file_list, function(a, b)
      return calculate_file_score(a.entry, config) > calculate_file_score(b.entry, config)
    end)

    -- Rebuild the project files table with only the top entries
    local new_project_files = {}
    for i = 1, config.file_scoring.max_file_history do
      if file_list[i] then
        new_project_files[file_list[i].file] = file_list[i].entry
      end
    end
    file_scores[normalized_project] = new_project_files
  end

  save_file_scores()
end

local function get_scored_files_for_project(project_path)
  local config = get_projectionist_config()

  if not config.file_scoring.enabled then
    return {}
  end

  -- Load file scores if not already loaded
  if not file_scores or vim.tbl_isempty(file_scores) then
    load_file_scores()
  end

  local normalized_project = vim.fn.fnamemodify(project_path, ":p"):gsub("/$", "")
  local project_files = file_scores[normalized_project]

  if not project_files then
    return {}
  end

  -- Convert to list and calculate scores
  local scored_files = {}
  for file_path, entry in pairs(project_files) do
    -- Check if file still exists
    if vim.fn.filereadable(file_path) == 1 then
      table.insert(scored_files, {
        path = file_path,
        score = calculate_file_score(entry, config),
        access_count = entry.access_count,
        last_accessed = entry.last_accessed,
      })
    end
  end

  -- Sort by score (highest first)
  table.sort(scored_files, function(a, b)
    return a.score > b.score
  end)

  return scored_files
end

local function save_projectionist_history()
  local config = get_projectionist_config()

  -- Ensure history directory exists
  if vim.fn.isdirectory(config.history_dir) == 0 then
    vim.fn.mkdir(config.history_dir, "p")
  end

  local file_path = get_projectionist_history_file()
  local file = io.open(file_path, "w")
  if file then
    file:write(vim.json.encode(projectionist_history))
    file:close()
  end
end

local function load_projectionist_history()
  local file_path = get_projectionist_history_file()
  if vim.fn.filereadable(file_path) == 1 then
    local file = io.open(file_path, "r")
    if file then
      local content = file:read("*a")
      file:close()
      if content and content ~= "" then
        local ok, entries = pcall(vim.json.decode, content)
        if ok and entries then
          projectionist_history = entries
          return true
        end
      end
    end
  end
  projectionist_history = {}
  return false
end

local function add_to_projectionist_history(project_path)
  -- Load history if not already loaded
  if not projectionist_history or vim.tbl_isempty(projectionist_history) then
    load_projectionist_history()
  end

  -- Normalize path
  local normalized_path = vim.fn.fnamemodify(project_path, ":p"):gsub("/$", "")

  -- Remove existing entries for the same project
  local new_history = {}
  for _, entry in ipairs(projectionist_history) do
    if entry.path ~= normalized_path then
      table.insert(new_history, entry)
    end
  end

  -- Add the new entry at the top
  table.insert(new_history, 1, {
    path = normalized_path,
    timestamp = os.time(),
    count = (projectionist_history[normalized_path] and projectionist_history[normalized_path].count or 0) + 1,
  })

  projectionist_history = new_history

  local config = get_projectionist_config()
  if #projectionist_history > config.max_history then
    table.remove(projectionist_history)
  end

  save_projectionist_history()
end

local function get_recent_projects()
  -- Load history if not already loaded
  if not projectionist_history or vim.tbl_isempty(projectionist_history) then
    load_projectionist_history()
  end

  local recent = {}
  for _, entry in ipairs(projectionist_history) do
    -- Check if the project directory still exists
    if vim.fn.isdirectory(entry.path) == 1 then
      table.insert(recent, entry.path)
    end
  end

  return recent
end

function M.get_visual_selection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end

function M.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

function M.fzf_projectionist()
  local fzf = require("fzf-lua")

  -- Get recent projects
  local recent_projects = get_recent_projects()

  -- Create command that shows recent projects first, then all others
  local base_cmd = "fd '.git$' --prune -utd ~/repos ~/repos_personal | xargs dirname"
  local cmd

  if #recent_projects > 0 then
    -- Create a temporary exclude file for the recent projects
    local exclude_file = vim.fn.tempname()
    local exclude_handle = io.open(exclude_file, "w")
    if exclude_handle then
      for _, recent_project in ipairs(recent_projects) do
        exclude_handle:write(recent_project .. "\n")
      end
      exclude_handle:close()
    end

    -- Create a script that shows recent projects first, then all others EXCEPT the recent ones
    local temp_script = vim.fn.tempname() .. ".sh"
    local script_content = string.format([[#!/usr/bin/env bash
# Show recent projects first
%s
# Show all other projects, excluding the recent ones
%s | grep -v -F -f %s
]],
      table.concat(vim.tbl_map(function(f) return "echo " .. vim.fn.shellescape(f) end, recent_projects), "\n"),
      base_cmd,
      vim.fn.shellescape(exclude_file))

    local temp_file = io.open(temp_script, "w")
    if temp_file then
      temp_file:write(script_content)
      temp_file:close()
      vim.fn.system("chmod +x " .. temp_script)
      cmd = temp_script

      -- Clean up after a delay
      vim.defer_fn(function()
        vim.fn.delete(temp_script)
        vim.fn.delete(exclude_file)
      end, 5000)
    else
      cmd = base_cmd
    end
  else
    cmd = base_cmd
  end

  -- Wrap actions to track history
  local function wrap_projectionist_action(action)
    return function(selected, opts)
      if selected and #selected > 0 and selected[1] then
        add_to_projectionist_history(selected[1])
      end

      if action then
        return action(selected, opts)
      end
    end
  end

  -- Enhanced file action that uses scoring
  local function scored_files_action(selected, opts)
    if not selected or #selected == 0 or not selected[1] then
      return
    end

    local project_path = selected[1]
    add_to_projectionist_history(project_path)

    -- Get scored files for this project
    local scored_files = get_scored_files_for_project(project_path)
    local config = get_projectionist_config()

    if config.file_scoring.enabled and #scored_files > 0 then
      -- Create a command that shows scored files first, then all other files
      local base_files_cmd = string.format("fd --type f --hidden --follow --exclude .git . %s",
        vim.fn.shellescape(project_path))

      -- Create temporary file with scored files
      local scored_files_temp = vim.fn.tempname()
      local scored_handle = io.open(scored_files_temp, "w")
      if scored_handle then
        for _, file_entry in ipairs(scored_files) do
          scored_handle:write(file_entry.path .. "\n")
        end
        scored_handle:close()
      end

      -- Create script that shows scored files first, then others
      local temp_script = vim.fn.tempname() .. ".sh"
      local script_content = string.format([[#!/usr/bin/env bash
# Show scored files first (with score indicators)
while IFS= read -r file; do
  if [ -f "$file" ]; then
    echo "$file"
  fi
done < %s
# Show all other files, excluding the scored ones
%s | grep -v -F -f %s 2>/dev/null || true
]],
        vim.fn.shellescape(scored_files_temp),
        base_files_cmd,
        vim.fn.shellescape(scored_files_temp))

      local temp_file = io.open(temp_script, "w")
      if temp_file then
        temp_file:write(script_content)
        temp_file:close()
        vim.fn.system("chmod +x " .. temp_script)

        -- Use the scored files command
        fzf.fzf_exec(temp_script, {
          cwd = project_path,
          actions = {
            ["default"] = function(file_selected, file_opts)
              if file_selected and #file_selected > 0 and file_selected[1] then
                -- Track file access
                add_file_access(project_path, file_selected[1])
                -- Open the file
                vim.cmd("edit " .. vim.fn.fnameescape(file_selected[1]))
              end
            end,
            ["ctrl-v"] = function(file_selected, file_opts)
              if file_selected and #file_selected > 0 and file_selected[1] then
                add_file_access(project_path, file_selected[1])
                vim.cmd("vsplit " .. vim.fn.fnameescape(file_selected[1]))
              end
            end,
            ["ctrl-x"] = function(file_selected, file_opts)
              if file_selected and #file_selected > 0 and file_selected[1] then
                add_file_access(project_path, file_selected[1])
                vim.cmd("split " .. vim.fn.fnameescape(file_selected[1]))
              end
            end,
            ["ctrl-t"] = function(file_selected, file_opts)
              if file_selected and #file_selected > 0 and file_selected[1] then
                add_file_access(project_path, file_selected[1])
                vim.cmd("tabedit " .. vim.fn.fnameescape(file_selected[1]))
              end
            end,
          },
          prompt = "Files> ",
          winopts = {
            title = " " .. vim.fn.fnamemodify(project_path, ":t") .. " - Scored Files ",
            title_pos = "center",
          },
        })

        -- Clean up after a delay
        vim.defer_fn(function()
          vim.fn.delete(temp_script)
          vim.fn.delete(scored_files_temp)
        end, 5000)
      else
        -- Fallback to regular files if script creation fails
        fzf.files({ cwd = project_path })
      end
    else
      -- Fallback to regular files if scoring is disabled or no scored files
      fzf.files({ cwd = project_path })
    end
  end

  fzf.fzf_exec(cmd, {
    actions = {
      ["default"] = scored_files_action,
      ["ctrl-f"] = wrap_projectionist_action(function(selected, _)
        fzf.grep_project({ cwd = selected[1] })
      end),
      ["ctrl-r"] = wrap_projectionist_action(function(selected, _)
        fzf.oldfiles({ cwd = selected[1] })
      end),
      ["ctrl-g"] = wrap_projectionist_action(function(selected, _)
        local windows = vim.api.nvim_list_wins()
        for _, v in pairs(windows) do
          local status, _ = pcall(vim.api.nvim_win_get_var, v, "fugitive_status")
          if status then
            pcall(vim.api.nvim_win_close, v, false)
          end
        end

        vim.cmd(string.format(
          [[
        function! GitDir()
        return "%s/.git"
        endfunction

        function! GCWDComplete(A, L, P) abort
        return fugitive#Complete(a:A, a:L, a:P, {'git_dir': GitDir() })
        endfunction

        command! -bang -nargs=? -range=-1 -complete=customlist,GCWDComplete GCWD exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>,   { 'git_dir': GitDir()})
        ]],
          selected[1]
        ))

        vim.cmd.GCWD()
        local current_buf = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= current_buf then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
        vim.fn.chdir(selected[1])
      end),
    },
    prompt = "Projects> ",
    winopts = {
      title = " Recent Projects First ",
      title_pos = "center",
    },
  })
end

-- Projectionist utility functions
function M.clear_projectionist_history()
  local config = get_projectionist_config()
  local file_path = get_projectionist_history_file()

  if vim.fn.filereadable(file_path) == 1 then
    vim.fn.delete(file_path)
  end

  projectionist_history = {}
  print("Projectionist history cleared!")
end

function M.clear_file_scores()
  local config = get_projectionist_config()
  local file_path = get_file_scores_file()

  if vim.fn.filereadable(file_path) == 1 then
    vim.fn.delete(file_path)
  end

  file_scores = {}
  print("File scores cleared!")
end

function M.debug_file_scores(project_path)
  load_file_scores()

  print("=== FILE SCORES DEBUG ===")
  local config = get_projectionist_config()
  print("File scoring enabled: " .. (config.file_scoring.enabled and "yes" or "no"))
  print("Scores directory: " .. config.history_dir)

  local file_path = get_file_scores_file()
  print("Scores file: " .. file_path)
  print("Scores file exists: " .. (vim.fn.filereadable(file_path) == 1 and "yes" or "no"))

  if project_path then
    local normalized_project = vim.fn.fnamemodify(project_path, ":p"):gsub("/$", "")
    print("Project: " .. normalized_project)

    local scored_files = get_scored_files_for_project(project_path)
    print("Scored files count: " .. #scored_files)

    for i, file_entry in ipairs(scored_files) do
      print(string.format("  %d: %s (score: %.3f, count: %d)",
        i,
        vim.fn.fnamemodify(file_entry.path, ":t"),
        file_entry.score,
        file_entry.access_count))
    end
  else
    print("All projects with scored files:")
    for project, files in pairs(file_scores) do
      local count = 0
      for _ in pairs(files) do count = count + 1 end
      print("  " .. project .. " (" .. count .. " files)")
    end
  end
end

function M.debug_projectionist_history()
  load_projectionist_history()
  load_file_scores()

  print("=== FZF PROJECTIONIST DEBUG ===")
  local config = get_projectionist_config()
  print("History directory: " .. config.history_dir)
  print("History directory exists: " .. (vim.fn.isdirectory(config.history_dir) == 1 and "yes" or "no"))

  local file_path = get_projectionist_history_file()
  print("History file: " .. file_path)
  print("History file exists: " .. (vim.fn.filereadable(file_path) == 1 and "yes" or "no"))

  print("Loaded history:")
  if projectionist_history and #projectionist_history > 0 then
    for i, entry in ipairs(projectionist_history) do
      print("  " ..
        i .. ": " .. entry.path .. " (timestamp: " .. entry.timestamp .. ", count: " .. (entry.count or 0) .. ")")
    end
  else
    print("  No history found")
  end

  local recent = get_recent_projects()
  print("Recent projects count: " .. #recent)
  for i, project in ipairs(recent) do
    print("  " .. i .. ": " .. project)
  end

  -- File scoring debug info
  print("\n=== FILE SCORING DEBUG ===")
  print("File scoring enabled: " .. (config.file_scoring.enabled and "yes" or "no"))
  print("Max file history: " .. config.file_scoring.max_file_history)
  print("Recency weight: " .. config.file_scoring.recency_weight)
  print("Frequency weight: " .. config.file_scoring.frequency_weight)

  local scores_file = get_file_scores_file()
  print("File scores file: " .. scores_file)
  print("File scores file exists: " .. (vim.fn.filereadable(scores_file) == 1 and "yes" or "no"))

  local total_projects = 0
  local total_files = 0
  for project, files in pairs(file_scores) do
    total_projects = total_projects + 1
    for _ in pairs(files) do
      total_files = total_files + 1
    end
  end
  print("Projects with scored files: " .. total_projects)
  print("Total scored files: " .. total_files)
end

function M.setup_projectionist_auto_history()
  local config = get_projectionist_config()

  -- Load existing data
  load_projectionist_history()
  load_file_scores()

  if config.auto_history then
    -- Auto-track when changing directories to git repositories
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        local cwd = vim.fn.getcwd()
        -- Check if current directory is a git repository
        if vim.fn.isdirectory(cwd .. "/.git") == 1 then
          add_to_projectionist_history(cwd)
        end
      end,
      desc = "Auto-add git repositories to projectionist history",
    })
  end

  -- Auto-track file access when opening files
  if config.file_scoring.enabled then
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      callback = function()
        local file_path = vim.fn.expand("%:p")
        local project_root = vim.fn.system("git -C " ..
          vim.fn.shellescape(vim.fn.expand("%:h")) .. " rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

        -- Only track if we're in a git repository and the file is readable
        if vim.v.shell_error == 0 and vim.fn.filereadable(file_path) == 1 and file_path ~= "" then
          add_file_access(project_root, file_path)
        end
      end,
      desc = "Auto-track file access for scoring",
    })
  end
end

function M.split(string, delimiter)
  local Table = {}
  local fpat = "(.-)" .. delimiter
  local last_end = 1
  local s, e, cap = string:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = string:find(fpat, last_end)
  end
  if last_end <= #string then
    cap = string:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

return M

