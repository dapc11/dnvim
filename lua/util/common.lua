local M = {}

M.ignored_filetypes = {
  "DressingSelect",
  "Jaq",
  "Markdown",
  "PlenaryTestPopup",
  "TelescopePrompt",
  "blame",
  "checkhealth",
  "dap-repl",
  "dapui_scopes",
  "fugitive",
  "fugitiveblame",
  "fzf",
  "git",
  "harpoon",
  "help",
  "lazy",
  "lspinfo",
  "man",
  "mason",
  "neo-tree",
  "neotest-output",
  "neotest-output-panel",
  "neotest-summary",
  "netrw",
  "notify",
  "oil",
  "qf",
  "spectre_panel",
  "startuptime",
  "tsplayground",
}

function M.GetVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end

function M.enable_format_on_save()
  print("Formatting enabled")
  vim.api.nvim_create_augroup("lsp_format_on_save", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = "lsp_format_on_save",
    callback = function()
      local buftype = vim.bo.filetype
      if buftype == "go" or buftype == "lua" then
        require("conform").format()
      end
    end,
  })
end

function M.clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = name })
  if not exists then
    print("ignoring request to clear autocmds from non-existent group " .. name)
    return
  end
  vim.schedule(function()
    local status_ok, _ = xpcall(function()
      vim.api.nvim_clear_autocmds({ group = name })
    end, debug.traceback)
    if not status_ok then
      print("problems detected while clearing autocmds from " .. name)
      vim.print(debug.traceback())
    end
  end)
end

function M.disable_format_on_save()
  print("Formatting disabled")
  M.clear_augroup("lsp_format_on_save")
end

function M.Toggle_format_on_save()
  local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_format_on_save",
    event = "BufWritePre",
  })
  if not exists or #autocmds == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

return M
