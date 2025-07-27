function Gsearch()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({
    cmd = "Gclog",
    args = {
      "-G" .. input .. " --",
    },
  })
end

function GitSearchCurrentFileHistory()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({
    cmd = "Gclog",
    args = {
      "-G" .. input .. " -- %",
    },
  })
end

local map = require("util").map
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
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
    keys = {
      { "<leader>ge", "<cmd>Gedit<CR>", desc = "Edit" },
      { "<leader>gg", "<cmd>Git<CR>" },
      { "<leader>gd", "<cmd>Gvdiffsplit!<CR>", desc = "3-way Diff" },
      { "<leader>gD", "<cmd>Gvdiffsplit<CR>", desc = "Diff" },
      { "<leader>gb", "<cmd>Git blame --date=short<CR>", desc = "Blame" },
      {
        "<leader>ff",
        function()
          vim.cmd.Ggrep({ "-q " .. require("util").get_visual_selection() })
        end,
        mode = "v",
        desc = "Git Grep",
      },
      { "<leader>ff", ":Git grep -q ", desc = "Git Grep" },
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
      { "<leader>gs", GitSearchCurrentFileHistory, desc = "Search Current File History" },
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
  },
}
