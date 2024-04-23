local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set({ "v", "n" }, "<leader>cF", ":%!jq '.'", { desc = "Format", buffer = bufnr })
vim.keymap.set(
  "n",
  "<leader>cl",
  ":%!jq -r '\"\\(.timestamp)\t\\(.severity)\t\\(.message)\"'<CR>",
  { desc = "Make logs readable", buffer = bufnr }
)

local function open_CVE_in_browser()
  local cve = string.match(vim.fn.getline("."), "CVE%-%d+%-%d+")
  if cve then
    vim.fn.jobstart({ "firefox", "https://nvd.nist.gov/vuln/detail/" .. cve }, { detach = true })
  else
    print("No CVE found in the current line.")
  end
end

vim.keymap.set("n", "gv", open_CVE_in_browser, { desc = "Goto CVE Definition", buffer = bufnr })
