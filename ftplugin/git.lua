vim.keymap.set("n", "gv", function()
  local jira_id = string.match(vim.fn.getline("."), require("secret").jira_pattern)
  if jira_id then
    vim.fn.jobstart({ "xdg-open", require("secret").jira_url .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end, { desc = "Goto Jira Definition", buffer = true })
