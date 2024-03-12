local bufnr = vim.api.nvim_get_current_buf()


local goc = require("nvim-goc")

vim.keymap.set("n", "<Leader>ccc", goc.Coverage, { silent = true, buffer = bufnr, desc = "Go Coverage" })
vim.keymap.set("n", "<Leader>ccx", goc.ClearCoverage, { silent = true, buffer = bufnr, desc = "Go Clear Coverage" })

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

vim.keymap.set("n", "<leader>ccb", Cf, { silent = true, buffer = bufnr, desc = "Coverage in Browser" })
