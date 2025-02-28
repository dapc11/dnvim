local goc = require("nvim-goc")

vim.keymap.set("n", "<Leader>cd", function()
  vim.cmd.GoDoc()
end, { silent = true, buffer = true, desc = "Docs" })
vim.keymap.set(
  "n",
  "<Leader>ccc",
  goc.Coverage,
  { silent = true, buffer = true, desc = "Go Coverage" }
)
vim.keymap.set(
  "n",
  "<Leader>ccx",
  goc.ClearCoverage,
  { silent = true, buffer = true, desc = "Go Clear Coverage" }
)

function Cf(testCurrentFunction)
  local cb = function(path)
    if path then
      vim.cmd(':silent exec "!xdg-open ' .. path .. '"')
    end
  end

  if testCurrentFunction then
    goc.CoverageFunc(nil, cb, 0)
  else
    goc.Coverage(nil, cb)
  end
end

vim.keymap.set(
  "n",
  "<leader>ccb",
  Cf,
  { silent = true, buffer = true, desc = "Coverage in Browser" }
)
vim.keymap.set("n", "<Leader>dn", function()
  require("dap-go").debug_test()
end, { desc = "Run nearest" })
