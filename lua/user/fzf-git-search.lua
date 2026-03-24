local function parse_search_query(query)
  local includes, excludes = {}, {}
  for term in query:gmatch("%S+") do
    if term:match("^!") then
      table.insert(excludes, term:sub(2))
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

  local grep_terms = table.concat(vim.tbl_map(vim.fn.shellescape, includes), " ")
  local cmd = string.format("git rev-list --all | xargs -P4 -n100 git grep -n -F %s 2>/dev/null || true", grep_terms)

  vim.notify("Searching git history...")
  local results = vim.fn.systemlist(cmd)
  if #results == 0 then
    return {}
  end

  local entries = {}
  for _, line in ipairs(results) do
    if line ~= "" then
      local commit, file, line_num, content = line:match("^([^:]+):([^:]+):(%d+):(.*)$")
      if commit and file and line_num and content then
        local should_exclude = false
        for _, exclude_term in ipairs(excludes) do
          if content:lower():find(exclude_term:lower(), 1, true) then
            should_exclude = true
            break
          end
        end
        if not should_exclude then
          table.insert(entries, string.format("%s:%s:%s %s", commit:sub(1, 8), file, line_num, content:gsub("^%s+", "")))
        end
      end
    end
  end

  if #entries > 0 then
    vim.notify(string.format("Found %d matches", #entries))
  end
  return entries
end

local function create_git_actions(action)
  return function(selected)
    if #selected == 0 then
      return
    end
    local commit, file, line_num = selected[1]:match("^([^:]+):([^:]+):(%d+)")
    if commit and file and line_num then
      vim.cmd(string.format("%s %s:%s", action, commit, file))
      vim.api.nvim_win_set_cursor(0, { tonumber(line_num), 0 })
    end
  end
end

return function()
  vim.ui.input({ prompt = "Git Search: " }, function(search_term)
    if not search_term or search_term == "" then
      return
    end

    local entries = search_git_history(search_term)
    if #entries == 0 then
      vim.notify("No matches found")
      return
    end

    local fzf = require("fzf-lua")
    fzf.fzf_exec(entries, {
      prompt = string.format("Git Search (%s)> ", search_term),
      winopts = {
        title = string.format("Git History: %s (%d results)", search_term, #entries),
        title_pos = "center",
        preview = { hidden = "nohidden" },
      },
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
              commit, file, line_num, lang ~= "" and lang or "txt"
            )
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
