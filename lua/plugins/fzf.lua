return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons", "vijaymarupudi/nvim-fzf", "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    local actions = require("fzf-lua.actions")
    local fzf = require("fzf-lua")
    fzf.setup({
      "max-perf",
      fzf_colors = {
        ["bg"] = { "bg", "Normal" },
        ["bg+"] = { "bg", "Normal" },
        ["gutter"] = "-1",
        ["border"] = "-1",
      },
      winopts = {
        preview = {
          hidden = "hidden",
        },
      },
      keymap = {
        builtin = {
          ["<C-p>"] = "toggle-preview",
        },
        fzf = {
          ["ctrl-p"] = "toggle-preview",
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
        },
      },
      grep = {
        rg_glob = false, -- default to glob parsing?
        glob_flag = "--iglob", -- for case sensitive globs use '--glob'
        glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
        actions = {
          ["ctrl-l"] = { actions.grep_lgrep },
          ["ctrl-g"] = { actions.toggle_ignore },
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
      { "<leader><leader>", fzf.grep_visual, desc = "Live Grep Selection", mode = "v" },
      { "<C-f>", fzf.lgrep_curbuf, desc = "Find in Current Buffer" },
      {
        "<C-p>",
        function()
          require("util.common").Fzf_projectionist()
        end,
        desc = "Find Project",
      },
    }
  end,
}
