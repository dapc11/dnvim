local bufnr = vim.api.nvim_get_current_buf()
GetVisualSelection = require("util.common").GetVisualSelection

local function open_jira_in_browser()
  local jira_id = string.match(vim.fn.getline("."), require("secret").jira_pattern)
  if jira_id then
    vim.fn.jobstart({ "xdg-open", require("secret").jira_url .. jira_id }, { detach = true })
  else
    print("No Jira ID found in the current line.")
  end
end

vim.keymap.set("n", "gj", open_jira_in_browser, { desc = "Find Usages", buffer = bufnr })
vim.keymap.set("n", "gf", function()
  vim.api.nvim_exec("tab Git show " .. vim.call("expand", "<cword>"), true)
end, { desc = "Find Usages", buffer = bufnr })
