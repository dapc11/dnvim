return {
  name = "run",
  builder = function()
    local file = vim.fn.expand("%:p")
    local cmd = { file }
    if vim.bo.filetype == "go" then
      cmd = { "go", "run", file }
    end
    if vim.bo.filetype == "sh" then
      cmd = { "sh", file }
    end
    if vim.bo.filetype == "python" then
      cmd = { "python3", file }
    end
    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "sh", "python", "go" },
  },
}
