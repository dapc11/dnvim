vim.cmd([[
    function! HighlightTodo()
        match none
        match Todo /TODO/
    endfunc
    augroup QFClose
        autocmd WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
        autocmd!
    augroup END
    augroup dapc
    autocmd!
        autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>
        autocmd BufReadPost,BufNewFile * :call HighlightTodo()

        function TelescopeIfEmpty()
            if @% == ""
                " No filename for current buffer
                Telescope find_files
            elseif filereadable(@%) == 0
                " File doesn't exist yet
                Telescope find_files
            elseif line('$') == 1 && col('$') == 1
                " File is empty
                Telescope find_files
            endif
        endfunction

        au VimEnter * call TelescopeIfEmpty()
    augroup END
]])

local augroups = {}

augroups.buf_write_pre = {
  mkdir_before_saving = {
    event = { "BufWritePre", "FileWritePre" },
    pattern = "*",
    -- TODO: Replace vimscript function
    command = [[ silent! call mkdir(expand("<afile>:p:h"), "p") ]],
  },
  trim_extra_spaces_and_newlines = {
    event = "BufWritePre",
    pattern = "*",
    -- TODO: Replace vimscript function
    command = [[
			let current_pos = getpos(".")
			silent! %s/\v\s+$|\n+%$//e
			silent! call setpos(".", current_pos)
		]],
  },
}

augroups.filetype_behaviour = {
  remove_colorcolumn = {
    event = "FileType",
    pattern = { "fugitive*", "git" },
    callback = function()
      vim.opt_local.colorcolumn = ""
    end,
  },
}

augroups.misc = {
  highlight_yank = {
    event = "TextYankPost",
    pattern = "*",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300, on_visual = true })
    end,
  },
  unlist_terminal = {
    event = "TermOpen",
    pattern = "*",
    callback = function()
      vim.opt_local.buflisted = false
    end,
  },
  set_cursorline = {
    event = { "InsertLeave", "WinEnter" },
    pattern = "*",
    callback = function()
      vim.opt.cursorline = true
    end,
  },
  remove_cursorline = {
    event = { "InsertEnter", "WinLeave" },
    pattern = "*",
    callback = function()
      vim.opt.cursorline = false
    end,
  },
}

augroups.prose = {
  wrap = {
    event = "FileType",
    pattern = { "markdown", "tex" },
    callback = function()
      vim.opt_local.wrap = true
    end,
  },
}

augroups.quit = {
  quit_with_q = {
    event = "FileType",
    pattern = { "checkhealth", "fugitive", "git*", "help", "lspinfo" },
    callback = function()
      -- vim.api.nvim_win_close(0, true) -- TODO: Replace vim command with this
      vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close!<cr>", { noremap = true, silent = true })
    end,
  },
}

for group, commands in pairs(augroups) do
  local augroup = vim.api.nvim_create_augroup("AU_" .. group, { clear = true })

  for _, opts in pairs(commands) do
    local event = opts.event
    opts.event = nil
    opts.group = augroup
    vim.api.nvim_create_autocmd(event, opts)
  end
end
