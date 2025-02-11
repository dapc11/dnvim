vim.keymap.set("n", "gv", function()
  local jira_id = string.match(vim.fn.getline("."), require("secret").JIRA_PATTERN)
  if jira_id then
    print(jira_id)
    vim.fn.jobstart({ "xdg-open", require("secret").JIRA_URL .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end, { desc = "Goto Jira Definition", buffer = true })
