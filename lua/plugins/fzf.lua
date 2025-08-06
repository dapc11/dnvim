return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons", "vijaymarupudi/nvim-fzf", "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    local actions = require("fzf-lua.actions")
    local fzf = require("fzf-lua")
    fzf.setup({
      "max-perf",
      files = {
        fd_opts = " --color=never --type f --hidden --follow --exclude .svn --exclude .git --exclude vendor",
      },
      grep = {
        actions = {
          ["ctrl-h"] = { actions.toggle_ignore },
        },
      },
      git = {
        files = {
          cmd = "fd --color=never --type f --type l --exclude .git",
        },
      },
      fzf_colors = {
        ["bg+"] = { "bg", "CursorLine" },
        ["gutter"] = { "fg", "NeoTreeStatusLineNC" }, -- Matches background of catppuccin-machiato
        ["hl+"] = { "fg", "Error" }, -- Current line match
        ["hl"] = { "fg", "Error" }, -- Other line matches
        ["separator"] = { "fg", "NeoTreeStatusLineNC" }, -- Matches background of catppuccin-machiato
        ["scrollbar"] = { "fg", "CursorLine" },
        ["header"] = { "fg", "CursorLine" },
        ["spinner"] = { "fg", "CursorLine" },
        ["pointer"] = { "fg", "Normal" },
      },
      winopts = {
        preview = {
          hidden = "hidden",
        },
      },
      keymap = {
        builtin = {
          ["<C-?>"] = "toggle-help",
          ["<S-down>"] = "preview-page-down",
          ["<S-up>"] = "preview-page-up",
          ["<S-left>"] = "preview-page-reset",
        },
        fzf = {
          ["ctrl-z"] = "abort",
          ["ctrl-x"] = "unix-line-discard",
          ["ctrl-d"] = "half-page-down",
          ["ctrl-u"] = "half-page-up",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
          ["shift-down"] = "preview-page-down",
          ["shift-up"] = "preview-page-up",
          ["ctrl-p"] = "toggle-preview",
          ["ctrl-q"] = "select-all+accept",
        },
      },
      actions = {
        files = {
          ["default"] = function(selected, opts)
            if #selected > 1 then
              local qf_list = {}
              for i = 1, #selected do
                local file = fzf.path.entry_to_file(selected[i])
                local text = selected[i]:match(":%d+:%d?%d?%d?%d?:?(.*)$")
                table.insert(qf_list, {
                  filename = file.path,
                  lnum = file.line,
                  col = file.col,
                  text = text,
                })
              end
              vim.fn.setqflist(qf_list)
              vim.cmd([[copen]])
            else
              actions.file_edit(selected, opts)
            end
          end,
          ["ctrl-x"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["alt-q"] = actions.file_sel_to_qf,
          ["alt-l"] = actions.file_sel_to_ll,
        },
        buffers = {
          ["default"] = actions.buf_edit,
          ["ctrl-v"] = actions.buf_vsplit,
          ["ctrl-t"] = actions.buf_tabedit,
        },
      },
    })
  end,
  keys = function()
    local fzf = require("fzf-lua")
    return {
      { "<leader>r", fzf.oldfiles, desc = "Find Recent Files" },
      { "<leader>b", fzf.buffers, desc = "Find Open Buffers" },
      { "<leader>n", fzf.files, desc = "Find Tracked Files" },
      { "<leader>N", fzf.git_status, desc = "Find Untracked Files" },
      { "<leader>fc", fzf.command_history, desc = "Find in Command History" },
      { "<M-x>", fzf.commands, desc = "Find Commands" },
      {
        "<leader>fä",
        function()
          fzf.files({ cwd = "~/.config" })
        end,
        desc = "Find in Dotfiles",
      },
      {
        "<leader>fÄ",
        function()
          fzf.files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find in Plugin Files",
      },
      {
        "<leader>fx",
        function()
          fzf.files({ cwd = "~/Downloads/" })
        end,
        desc = "Find in Downloads",
      },
      { "<leader>fh", fzf.helptags, desc = "Find Help" },
      { "<leader>fH", fzf.highlights, desc = "Find Highlights" },
      { "<leader><leader>", fzf.grep_project, desc = "Grep" },
      { "<leader>R", fzf.resume, desc = "Resume" },
      { "<leader><leader>", fzf.grep_visual, desc = "Live Grep Selection", mode = "v" },
      {
        "<C-f>",
        function()
          fzf.lgrep_curbuf({ search = require("util.common").get_visual_selection() })
        end,
        desc = "Live Grep Selection",
        mode = "v",
      },
      { "<C-f>", fzf.lgrep_curbuf, desc = "Find in Current Buffer" },
      {
        "<C-p>",
        function()
          require("util.common").fzf_projectionist()
        end,
        desc = "Find Project",
      },
    }
  end,
}
