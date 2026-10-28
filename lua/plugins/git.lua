local function git_status_fn()
  local orig_buf = vim.api.nvim_get_current_buf()
  vim.cmd("Git")
  vim.cmd("only")
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      vim.schedule(function()
        local current_ft = vim.bo.filetype
        if
          current_ft ~= "gitcommit"
          and current_ft ~= "git"
          and current_ft ~= "fugitive"
          and vim.api.nvim_buf_is_valid(orig_buf)
        then
          vim.api.nvim_set_current_buf(orig_buf)
        end
      end)
    end,
  })
end

local function Gsearch()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({
    cmd = "Gclog",
    args = {
      "-G" .. input .. " --",
    },
  })
end

local map = require("util").map

return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      word_diff = false,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        if vim.bo[buffer].filetype == "oil" then
          return false
        end
        local gs = package.loaded.gitsigns
        map("n", "]h", function()
          if vim.wo.diff then
            return "]czz"
          end
          vim.schedule(function()
            gs.nav_hunk("next")
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, { buffer = buffer, desc = "Next Hunk", expr = true })
        map("n", "[h", function()
          if vim.wo.diff then
            return "[czz"
          end
          vim.schedule(function()
            gs.nav_hunk("prev")
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, { buffer = buffer, desc = "Previous hunk", expr = true })
        map({ "n", "v" }, "<leader>hs", gs.stage_hunk, { buffer = buffer, desc = "Stage Hunk" })
        map({ "n", "v" }, "<leader>hr", gs.reset_hunk, { buffer = buffer, desc = "Reset Hunk" })
        map("n", "<leader>hp", gs.preview_hunk, { buffer = buffer, desc = "Preview Hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { buffer = buffer, desc = "Blame Line" })
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
    config = function()
      vim.cmd("silent! runtime! syntax/diff.vim")
    end,
    keys = {
      { "<leader>ge", "<cmd>Gedit<CR>", desc = "Edit" },
      { "<leader>gg", git_status_fn },
      { "<leader>gG", "<cmd>Git<CR>" },
      { "<leader>gd", "<cmd>Gvdiffsplit!<CR>", desc = "3-way Diff" },
      { "<leader>gD", "<cmd>Gvdiffsplit<CR>", desc = "Diff" },
      {
        "<leader>ff",
        function()
          vim.cmd.Ggrep({ "-q " .. require("util").get_visual_selection() })
        end,
        mode = "v",
        desc = "Git Grep",
      },
      { "<leader>ff", ":Git grep -q ", desc = "Git Grep" },
      { "<leader>gb", function() require("user.blame").blame() end, desc = "Blame" },
      { "<leader>gb", function()
        local line1 = vim.fn.line("v")
        local line2 = vim.fn.line(".")
        if line1 > line2 then line1, line2 = line2, line1 end
        vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
        require("user.blame").blame_range(line1, line2)
      end, mode = "v", desc = "Blame selection" },
      {
        "<leader>gl",
        "<cmd>Git log --graph --pretty=format:'%h %cs %s <%an>%d' --abbrev-commit<CR><CR>",
        desc = "Git log",
      },
      {
        "<leader>gn",
        "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit origin/master..HEAD<CR><CR>",
        desc = "Show New Commits",
      },
      {
        "<leader>gN",
        "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit HEAD..origin/master<CR><CR>",
        desc = "Show Missing Commits",
      },
      { "<leader>gh", "<cmd>0Gclog<cr>", desc = "View File History" },
      { "<leader>gS", Gsearch, desc = "Search History" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewRefresh",
      "DiffviewLog",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
    },
    keys = {
      { "<leader>gm", "<cmd>Meld<cr>", desc = "Merge conflicts (Meld)" },
    },
    -- diff3_horizontal is the safe default: diff4_mixed needs a BASE pane and
    -- errors on add/add conflicts, which have no common ancestor. :Meld upgrades
    -- to diff4_mixed when every conflicted file does have one.
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)

      -- Conflict sides, re-choosable: pressing another key swaps the text in
      -- place rather than leaving undo as the only way back. Both schemes run
      -- left to right across the top row. See user.conflict-toggle.
      --
      --   <leader>ca / c1   OURS     left pane
      --   <leader>cb / c2   BASE     middle pane
      --   <leader>cc / c3   THEIRS   right pane
      --   <leader>c0        all three
      --   <leader>cr        put the markers back
      --
      -- DiffviewDiffBufWinEnter, not DiffviewViewPostLayout: diffview applies its
      -- own buffer keymaps when a diff buffer attaches, which happens after the
      -- layout event and would clobber these.
      vim.api.nvim_create_autocmd("User", {
        pattern = { "DiffviewDiffBufWinEnter", "DiffviewViewPostLayout" },
        group = vim.api.nvim_create_augroup("user_diffview_keys", { clear = true }),
        desc = "Re-choosable conflict keymaps",
        callback = function()
          vim.schedule(function()
            local conflict = require("user.conflict-toggle")
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_is_valid(buf) then
                conflict.attach(buf)
              end
            end
          end)
        end,
      })
    end,
  },
}
