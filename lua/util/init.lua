local M = {}

M.ignored_filetypes = {
  "DressingSelect",
  "Jaq",
  "Markdown",
  "PlenaryTestPopup",
  "blame",
  "checkhealth",
  "fugitiveblame",
  "fugitive",
  "git",
  "harpoon",
  "help",
  "lazy",
  "lspinfo",
  "man",
  "neo-tree",
  "neotest-output",
  "neotest-output-panel",
  "neotest-summary",
  "netrw",
  "notify",
  "oil",
  "pydoc",
  "qf",
  "spectre_panel",
  "startuptime",
  "tsplayground",
}
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- stylua: ignore
local function match(dir, pattern)
  if string.sub(pattern, 1, 1) == "=" then
    return vim.fn.fnamemodify(dir, ":t") == string.sub(pattern, 2, #pattern)
  else
    return vim.fn.globpath(dir, pattern) ~= ""
  end
end

local function parent_dir(dir)
  return vim.fn.fnamemodify(dir, ":h")
end

---Return project root of project_root_indicator
---@param project_root_indicator string
---@return string
function M.get_project_root(project_root_indicator)
  local current = vim.api.nvim_buf_get_name(0)
  local parent = parent_dir(current)

  while 1 do
    if match(parent, project_root_indicator) then
      return parent
    end

    current, parent = parent, parent_dir(parent)
    if parent == current then
      break
    end
  end
  return ""
end

local function snake_case(str)
  return str:gsub("%s+", "_"):gsub("[^%w_]", ""):lower()
end

local function title_case(str)
  local minor = {
    a = true, an = true, the = true, ["and"] = true, but = true, ["or"] = true, nor = true,
    yet = true, so = true, at = true, by = true, ["for"] = true, ["in"] = true, of = true,
    on = true, to = true, up = true, as = true, is = true, it = true,
  }
  local words = {}
  for word in str:gmatch("%S+") do
    table.insert(words, word)
  end
  for i, word in ipairs(words) do
    local lower = word:lower()
    if i == 1 or i == #words or not minor[lower] then
      words[i] = lower:sub(1, 1):upper() .. lower:sub(2)
    else
      words[i] = lower
    end
  end
  return table.concat(words, " ")
end

function M.create_note()
  local category = vim.fn.input("Category: ")
  local title = vim.fn.input("Note title: ")
  if title == "" then
    return
  end

  local file_name = category ~= "" and (snake_case(category) .. "_" .. snake_case(title) .. ".md") or (snake_case(title) .. ".md")
  local notes_dir = vim.fn.expand("~/notes/")

  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end

  local file_path = notes_dir .. file_name
  if vim.fn.filereadable(file_path) == 1 then
    print("File already exists: " .. file_path)
    return
  end

  local file = io.open(file_path, "w")
  if file then
    local heading = category ~= "" and ("# " .. category .. " - " .. title_case(title)) or ("# " .. title_case(title))
    file:write(heading .. "\n\n")
    file:close()
    print("Note created: " .. file_path)
    vim.cmd("edit " .. file_path)
  else
    print("Error creating note: " .. file_path)
  end
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

function M.jira_finder()
  local JIRA_PATTERN = os.getenv("JIRA_PATTERN") or ""
  local JIRA_URL = os.getenv("JIRA_URL") or ""

  if JIRA_PATTERN == "" or JIRA_URL == "" then
    print("JIRA configuration not found in environment variables.")
    return
  end

  local jira_id = string.match(vim.fn.getline("."), JIRA_PATTERN)
  if jira_id then
    print(jira_id)
    vim.fn.jobstart({ "xdg-open", JIRA_URL .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end

return M
