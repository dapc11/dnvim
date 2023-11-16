GetVisualSelection = require("util.common").GetVisualSelection
return {
  {
    "FabijanZulj/blame.nvim",
    opts = {
      date_format = "%Y/%m/%d",
    },
    keys = {
      { "<leader>gb", "<cmd>ToggleBlame<CR>", desc = "Git Blame" },
    },
  },
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
        map("n", "<leader>hB", function()
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
        "<leader>gl",
        "<cmd>Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit<CR><CR>",
        desc = "Git log",
      },
    },
  },
  {
    "dapc11/neogit",
    keys = { { "<C-g>", "<cmd>Neogit<CR>" } },
    config = true,
    dependencies = "nvim-lua/plenary.nvim",
  },
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    opts = function()
      return {
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "bottom",
            height = 15,
            win_opts = {},
          },
        },
      }
    end,
    keys = {
      { "<leader>gq", vim.cmd.DiffviewClose, desc = "Diffview Close" },
      { "<leader>gd", vim.cmd.DiffviewOpen, desc = "Diffview (all modified files)" },
      {
        "<leader>gh",
        function()
          vim.cmd.DiffviewFileHistory("%")
        end,
        desc = "Diffview Current File History",
      },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = {
      list_opener = "copen",
      default_mappings = {
        ours = "o",
        theirs = "t",
        none = "0",
        both = "b",
        next = "<",
        prev = ">",
      },
    },
  },
}
