local M = {}

M.ignored_filetypes = {
  "DressingSelect",
  "Jaq",
  "Markdown",
  "PlenaryTestPopup",
  "blame",
  "checkhealth",
  "dap-repl",
  "dapui_scopes",
  "fugitiveblame",
  "git",
  "godoc",
  "harpoon",
  "help",
  "lazy",
  "lspinfo",
  "man",
  "mason",
  "neo-tree",
  "neotest-output",
  "neotest-output-panel",
  "neotest-summary",
  "netrw",
  "notify",
  "oil",
  "pydoc",
  "qf",
  "snacks_dashboard",
  "spectre_panel",
  "startuptime",
  "toggleterm",
  "tsplayground",
}

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

function M.jira_finder()
  local jira_id = string.match(vim.fn.getline("."), require("secret").JIRA_PATTERN)
  if jira_id then
    print(jira_id)
    vim.fn.jobstart({ "xdg-open", require("secret").JIRA_URL .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end

return M
