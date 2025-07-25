-- Function to search for commits in the Git log.
function Gsearch()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({
    cmd = "Gclog",
    args = {
      "-G" .. input .. " --",
    },
  })
end

-- Searches for a commit containing the current buffer's contents in the Git log.
function GsearchCurrent()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({
    cmd = "Gclog",
    args = {
      "-G" .. input .. " -- %",
    },
  })
end

-- Cache table to store git repository checks keyed by directory path
local git_repo_cache = {}

local function is_git_repo(path)
  if git_repo_cache[path] ~= nil then
    return git_repo_cache[path]
  end
  -- This searches upward for a .git directory from the given path
  local git_dir = vim.fn.finddir(".git", path .. ";")
  local is_repo = git_dir ~= ""
  git_repo_cache[path] = is_repo
  return is_repo
end

local map = require("util").map
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    cond = function()
      local cwd = vim.fn.expand("%:p:h")
      return is_git_repo(cwd)
    end,
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
      { "<leader>gpp", "<cmd>Git push<CR>", desc = "Push" },
      { "<leader>gpf", "<cmd>Git fetch<CR>", desc = "Fetch" },
      { "<leader>gpr", "<cmd>Git fetch | Git rebase origin/master<CR>", desc = "Pull" },
      {
        "<leader>gps",
        "<cmd>Git submodule update --init --recursive<CR>",
        desc = "Update Submodules",
      },
      { "<leader>gC", ":Git fetch | Git checkout origin/master -b ", desc = "New Feature Branch" },
      {
        "<leader>f",
        function()
          vim.cmd.Ggrep({ "-q " .. require("util").get_visual_selection() })
        end,
        mode = "v",
        desc = "Git Grep",
      },
      { "<leader>f", ":Git grep -q ", desc = "Git Grep" },
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
      { "<leader>gs", GsearchCurrent, desc = "Search Current File History" },
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
