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
  large_files_enhancements = {
    event = "BufRead",
    pattern = "*",
    callback = function()
      if vim.fn.expand("%:t") == "lsp.log" or vim.bo.filetype == "help" then
        return
      end

      local size = vim.fn.getfsize(vim.fn.expand("%"))
      if size > 1024 * 1024 * 5 then
        local hlsearch = vim.opt.hlsearch
        local lazyredraw = vim.opt.lazyredraw
        local showmatch = vim.opt.showmatch

        vim.bo.undofile = false
        vim.wo.colorcolumn = ""
        vim.wo.relativenumber = false
        vim.wo.foldmethod = "manual"
        vim.wo.spell = false
        vim.opt.hlsearch = false
        vim.opt.lazyredraw = true
        vim.opt.showmatch = false

        vim.api.nvim_create_autocmd("BufDelete", {
          buffer = 0,
          callback = function()
            vim.opt.hlsearch = hlsearch
            vim.opt.lazyredraw = lazyredraw
            vim.opt.showmatch = showmatch
          end,
          desc = "set the global settings back to what they were before",
        })
      end
    end,
  },
  telescope_on_startup = {
    event = "VimEnter",
    pattern = "*",
    command = [[
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
        call TelescopeIfEmpty()
    ]],
  },
  quickfix_close = {
    event = "WinEnter",
    pattern = "*",
    command = [[ if winnr('$') == 1 && &buftype == "quickfix"|q|endif ]],
  },
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

augroups.lang = {
  python = {
    event = "FileType",
    pattern = { "py" },
    callback = function()
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.expandtab = true
    end,
  },
  lua = {
    event = "FileType",
    pattern = { "lua" },
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end,
  },
  yaml = {
    event = "FileType",
    pattern = { "yml", "yaml" },
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
      vim.opt_local.indentkeys:append("0#")
      vim.opt_local.indentkeys:append("<:>")
    end,
  },
}

augroups.prose = {
  wrap = {
    event = "FileType",
    pattern = { "markdown", "tex" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
      bmap(0, "n", "gO", "<cmd>Toc<cr>", { desc = "View ToC" })
    end,
  },
}

augroups.quit = {
  quit_with_q = {
    event = "FileType",
    pattern = { "checkhealth", "fugitive", "git*", "help", "lspinfo" },
    callback = function()
      bmap(0, "n", "q", "<cmd>close!<cr>")
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
