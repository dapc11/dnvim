GetVisualSelection = require("util.common").GetVisualSelection
function Gsearch()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({ cmd = "Gclog", args = {
    "-G" .. input .. " --",
  } })
end
function GsearchCurrent()
  local input = vim.fn.input("Search phrase> ", "")
  vim.cmd({ cmd = "Gclog", args = {
    "-G" .. input .. " -- %",
  } })
end

local map = require("util").map
return {
  {
    "lewis6991/gitsigns.nvim",
    events = lazyfile,
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      -- stylua: ignore
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        map("n", "]h", function() if vim.wo.diff then return "]czz" end vim.schedule(function() require("gitsigns").next_hunk() vim.fn.feedkeys("zz") end) return "<Ignore>" end, { buffer = buffer, desc = "Next Hunk", expr = true })
        map("n", "[h", function() if vim.wo.diff then return "[czz" end vim.schedule(function() require("gitsigns").prev_hunk() vim.fn.feedkeys("zz") end) return "<Ignore>"
        end, { buffer = buffer, desc = "Previous hunk", expr = true })
        map({ "n", "v" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { buffer = buffer, desc = "Stage Hunk"})
        map({ "n", "v" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { buffer = buffer, desc = "Reset Hunk" })
        map("n", "<leader>hp", gs.preview_hunk, { buffer = buffer, desc = "Preview Hunk" })
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { buffer = buffer, desc = "Blame Line" })
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
    -- stylua: ignore
    keys = {
      {"<leader>ge", "<cmd>Gedit<CR>", desc = "Edit" },
      { "<C-g>", "<cmd>Git<CR>" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Diff" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Blame" },
      { "<leader>gpg", "<cmd>Git push origin HEAD:refs/for/master<CR>", desc = "Push Gerrit" },
      { "<leader>gpp", "<cmd>Git push<CR>", desc = "Push Regular" },
      { "<leader>gf", "<cmd>Git fetch<CR>", desc = "Git Fetch" },
      { "<leader>gC", ":Git fetch | Git checkout origin/master -b ", desc = "Git Start New Feature Branch" },
      { "<leader>gr", "<cmd>Git pull --rebase<CR>", desc = "Git Pull Rebase" },
      { "<leader>gg", function() vim.cmd.Ggrep({ "-q " .. GetVisualSelection() }) end, mode = "v", desc = "Git Grep", },
      { "<leader>gg", ":Git grep -q ", desc = "Git Grep", },
      { "<leader>gl", "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit<CR><CR>", desc = "Git log", },
      { "<leader>gn", "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit origin/master..HEAD<CR><CR>", desc = "Git New", },
      { "<leader>gm", "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit HEAD..origin/master<CR><CR>", desc = "Git Missing", },
      { "<leader>gh", "<cmd>0Gclog<cr>", desc = "View File History" },
      { "<leader>gs", Gsearch, desc = "Git Search History"},
      { "<leader>gS", GsearchCurrent, desc = "Git Search Current File History"}
    },
  },
}
