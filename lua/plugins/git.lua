GetVisualSelection = require("util.common").GetVisualSelection
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc, expr)
          local ex = expr or false
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, expr = ex })
        end

        map("n", "]c", function()
          if vim.wo.diff then
            return "]czz"
          end
          vim.schedule(function()
            require("gitsigns").next_hunk()
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, "Next Hunk", true)

        map("n", "[c", function()
          if vim.wo.diff then
            return "[czz"
          end
          vim.schedule(function()
            require("gitsigns").prev_hunk()
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, "Previous hunk", true)
        map({ "n", "v" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hd", gs.detach, "Detach")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map({ "o", "x" }, "ih", "<cmd><C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
  },
  {
    "dapc11/vim-fugitive",
    lazy = false,
    keys = {
      { "<C-g>", "<cmd>Git<CR>" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Diff" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Blame" },
      { "<leader>gn", "<cmd>Git checkout -b", desc = "Create new Branch" },
      { "<leader>gp", "<cmd>Git push origin HEAD:refs/for/master<CR>", desc = "Push Gerrit" },
      { "<leader>gP", "<cmd>Git push<CR>", desc = "Push Regular" },
      { "<leader>gF", "<cmd>Git fetch<CR>", desc = "Git Fetch" },
      { "<leader>gr", "<cmd>Git pull --rebase<CR>", desc = "Git Pull Rebase" },
      {
        "<leader>gf",
        function()
          vim.cmd.Ggrep({ "-q " .. GetVisualSelection() })
        end,
        mode = "v",
        desc = "Git Grep",
      },
      {
        "<leader>gf",
        ":Git grep -q ",
        desc = "Git Grep",
      },
      {
        "<leader>gl",
        "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit<CR><CR>",
        desc = "Git log",
      },
      { "<leader>gh", "<cmd>0Gllog<cr>", desc = "View File History" },
      { "<leader>ge", "<cmd>Gedit<cr>", desc = "Edit Current Version" },
    },
  },
}
