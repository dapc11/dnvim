vim.keymap.set(
  "n",
  "gj",
  require("util.common").jira_finder,
  { desc = "Goto Jira Definition", buffer = true }
)
