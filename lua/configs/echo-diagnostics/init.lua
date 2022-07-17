local M = {}

function M.config()
  local status_ok, echo_diagnostics = pcall(require, "echo-diagnostics")
  if not status_ok then
    return
  end
  echo_diagnostics.setup({
    show_diagnostic_number = true,
    show_diagnostic_source = true,
  })
  vim.cmd([[
    autocmd CursorHold * lua require('echo-diagnostics').echo_line_diagnostic()
  ]])
end

return M
