return {
  {
    "lewis6991/gitsigns.nvim",
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

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "äc", function()
          if vim.wo.diff then
            return "]czz"
          end
          vim.schedule(function()
            require("gitsigns").next_hunk()
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "öc", function()
          if vim.wo.diff then
            return "[czz"
          end
          vim.schedule(function()
            require("gitsigns").prev_hunk()
            vim.fn.feedkeys("zz")
          end)
          return "<Ignore>"
        end, { expr = true })
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hB", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
  },
  {
    "dapc11/vim-fugitive",
    lazy = false,
    -- stylua: ignore
    keys = {
      { "<leader>gp", ":Git push origin HEAD:refs/for/master<cr>", desc = "Push Gerrit" },
      { "<leader>gP", ":Git push<cr>",                             desc = "Push Regular" },
      { "<leader>gb", ":Git blame<cr>",                            desc = "Git Blame" },
      { "<leader>gf", ":Git fetch<cr>",                            desc = "Git Fetch" },
      { "<leader>gr", ":Git pull --rebase<cr>",                    desc = "Git Pull Rebase" },
      {
        "<leader>gl",
        ":Git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit<cr><cr>",
        desc = "Git log",
      },
    },
  },
  {
    "NeogitOrg/neogit",
    commit = "5234a61a2b6bb26339bea628118d899e76a116e8",
    keys = { { "<C-g>", "<cmd>Neogit<cr>" } },
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
      local actions = require("diffview.actions")

      return {
        file_panel = {
          listing_style = "tree", -- One of 'list' or 'tree'
          tree_options = { -- Only applies when listing_style is 'tree'
            flatten_dirs = true, -- Flatten dirs that only contain one single dir
            folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
          },
          win_config = { -- See ':h diffview-config-win_config'
            position = "bottom",
            height = 15,
            win_opts = {},
          },
        },
        keymaps = {
          diff3 = {
            {
              { "n", "x" },
              "1do",
              actions.diffget("base"),
              { desc = "Obtain the diff hunk from the BASE version of the file" },
            },
            {
              { "n", "x" },
              "2do",
              actions.diffget("ours"),
              { desc = "Obtain the diff hunk from the OURS version of the file" },
            },
            {
              { "n", "x" },
              "3do",
              actions.diffget("theirs"),
              { desc = "Obtain the diff hunk from the THEIRS version of the file" },
            },
          },
          file_panel = {
            { "n", "öx", actions.prev_conflict, { desc = "Go to the previous conflict" } },
            { "n", "äx", actions.next_conflict, { desc = "Go to the next conflict" } },
          },
          file_history_panel = {
            {
              "n",
              "<down>",
              actions.next_entry,
              { desc = "Bring the cursor to the next file entry" },
            },
            {
              "n",
              "<up>",
              actions.prev_entry,
              { desc = "Bring the cursor to the previous file entry" },
            },
          },
        },
      }
    end,
    -- stylua: ignore
    keys = {
      { "<leader>gq", vim.cmd.DiffviewClose, desc = "Diffview Close" },
      { "<leader>gd", vim.cmd.DiffviewOpen,  desc = "Diffview (all modified files)" },
      {
        "<leader>gh",
        function()
          vim.cmd.DiffviewFileHistory("%")
        end,
        desc = "Diffview Current File History",
      },
    },
  },
}
