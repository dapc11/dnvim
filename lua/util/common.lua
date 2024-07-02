local M = {}

M.ignored_filetypes = {
  "DressingSelect",
  "Jaq",
  "Markdown",
  "PlenaryTestPopup",
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

function M.get_visual_selection()
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

function M.starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

function M.fzf_projectionist()
  local fzf = require("fzf-lua")
  fzf.fzf_exec("fd '.git$' --prune -utd ~/repos ~/repos_personal | xargs dirname", {
    actions = {
      ["default"] = function(selected, _)
        fzf.git_files({ cwd = selected[1] })
      end,
      ["ctrl-f"] = function(selected, _)
        fzf.grep_project({ cwd = selected[1] })
      end,
      ["ctrl-r"] = function(selected, _)
        fzf.oldfiles({ cwd = selected[1] })
      end,
      ["ctrl-g"] = function(selected, _)
        local windows = vim.api.nvim_list_wins()
        for _, v in pairs(windows) do
          local status, _ = pcall(vim.api.nvim_win_get_var, v, "fugitive_status")
          if status then
            pcall(vim.api.nvim_win_close, v, false)
          end
        end

        vim.cmd(string.format(
          [[
        function! GitDir()
        return "%s/.git"
        endfunction

        function! GCWDComplete(A, L, P) abort
        return fugitive#Complete(a:A, a:L, a:P, {'git_dir': GitDir() })
        endfunction

        command! -bang -nargs=? -range=-1 -complete=customlist,GCWDComplete GCWD exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>,   { 'git_dir': GitDir()})
        ]],
          selected[1]
        ))

        vim.cmd.GCWD()
        local current_buf = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= current_buf then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    },
  })
end

function M.split(string, delimiter)
  local Table = {}
  local fpat = "(.-)" .. delimiter
  local last_end = 1
  local s, e, cap = string:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = string:find(fpat, last_end)
  end
  if last_end <= #string then
    cap = string:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

return M
