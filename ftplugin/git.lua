local bufnr = vim.api.nvim_get_current_buf()

local function open_jira_in_browser()
  local jira_id = string.match(vim.fn.getline("."), require("secret").jira_pattern)
  if jira_id then
    vim.fn.jobstart({ "xdg-open", require("secret").jira_url .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end

vim.keymap.set("n", "gd", open_jira_in_browser, { desc = "Goto Jira Definition", buffer = bufnr })
