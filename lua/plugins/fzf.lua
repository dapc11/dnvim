return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons", "vijaymarupudi/nvim-fzf", "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    local actions = require("fzf-lua.actions")
    local utils = require("fzf-lua.utils")
    local fzf = require("fzf-lua")

    local function hl_validate(hl)
      return not utils.is_hl_cleared(hl) and hl or nil
    end
    fzf.setup({
      "max-perf",
      -- ignore all '.lua' and '.vim' files
      files = {
        fd_opts = " --color=never --type f --hidden --follow --exclude .svn --exclude .git --exclude vendor",
      },
      grep = {
        prompt = "Rg❯ ",
        input_prompt = "Grep For❯ ",
        multiprocess = false, -- run command in a separate process
        git_icons = false, -- show git icons?
        file_icons = false, -- show file icons?
        color_icons = false, -- colorize file|git icons
        rg_opts = " -g '!vendor' --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        -- rg_glob = true, -- default to glob parsing?
        actions = {
          ["ctrl-h"] = { actions.toggle_ignore },
        },
      },
      hls = {
        normal = hl_validate("TelescopeNormal"),
        border = hl_validate("TelescopeBorder"),
        title = hl_validate("TelescopePromptTitle"),
        help_normal = hl_validate("TelescopeNormal"),
        help_border = hl_validate("TelescopeBorder"),
        preview_normal = hl_validate("TelescopeNormal"),
        preview_border = hl_validate("TelescopeBorder"),
        preview_title = hl_validate("TelescopePreviewTitle"),
        -- builtin preview only
        cursor = hl_validate("Cursor"),
        cursorline = hl_validate("TelescopeSelection"),
        cursorlinenr = hl_validate("TelescopeSelection"),
        search = hl_validate("IncSearch"),
      },
      fzf_colors = {
        ["fg"] = { "fg", "Normal" },
        ["bg"] = { "bg", "Normal" },
        ["hl"] = { "fg", "TelescopeMatching" },
        ["fg+"] = { "fg", "TelescopeSelection" },
        ["bg+"] = { "bg", "TelescopeSelection" },
        ["hl+"] = { "fg", "TelescopeMatching" },
        ["info"] = { "fg", "TelescopeMultiSelection" },
        ["border"] = { "fg", "TelescopeBorder" },
        ["gutter"] = { "bg", "Normal" },
        ["query"] = { "fg", "TelescopePromptNormal" },
        ["prompt"] = { "fg", "TelescopePromptPrefix" },
        ["pointer"] = { "fg", "TelescopeSelectionCaret" },
        ["marker"] = { "fg", "TelescopeSelectionCaret" },
        ["header"] = { "fg", "TelescopeTitle" },
      },
      winopts = {
        preview = {
          hidden = "hidden",
        },
      },
      keymap = {
        -- These override the default tables completely
        -- no need to set to `false` to disable a bind
        -- delete or modify is sufficient
        builtin = {
          -- neovim `:tmap` mappings for the fzf win
          ["<C-?>"] = "toggle-help",
          ["<S-down>"] = "preview-page-down",
          ["<S-up>"] = "preview-page-up",
          ["<S-left>"] = "preview-page-reset",
        },
        fzf = {
          -- fzf '--bind=' options
          ["ctrl-z"] = "abort",
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-f"] = "half-page-down",
          ["ctrl-b"] = "half-page-up",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ["f3"] = "toggle-preview-wrap",
          ["f4"] = "toggle-preview",
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
      { "<leader>gc", fzf.git_branches, desc = "Checkout Branch" },
      { "<leader>r", fzf.oldfiles, desc = "Find Recent Files" },
      { "<leader>b", fzf.buffers, desc = "Find Open Buffers" },
      { "<leader>n", fzf.files, desc = "Find Tracked Files" },
      { "<leader>N", fzf.git_status, desc = "Find Untracked Files" },
      {
        "<leader>lc",
        function()
          fzf.files({ cwd = "~/.config" })
        end,
        desc = "Find in Dotfiles",
      },
      {
        "<leader>lC",
        function()
          fzf.files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find in Plugin Files",
      },
      {
        "<leader>ld",
        function()
          fzf.files({ cwd = "~/Downloads/" })
        end,
        desc = "Find in Downloads",
      },
      { "<leader>lh", fzf.helptags, desc = "Find Help" },
      { "<leader>lH", fzf.highlights, desc = "Find Highlights" },
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
        "<leader>xt",
        function()
          fzf.grep_project({ search = "TODO", path_shorten = true })
        end,
        desc = "Find in TODOs in project",
      },
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
