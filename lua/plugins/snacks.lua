return {
  "folke/snacks.nvim",
  opts = function()
    Snacks.toggle.profiler():map("<leader>pp")
    -- Toggle the profiler highlights
    Snacks.toggle.profiler_highlights():map("<leader>ph")
    return {
      scratch = {},
      profiler = {},
      picker = {},
      bigfile = {},
    }
  end,
  keys = {
    {
      "<leader>xs",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>xS",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>ps",
      function()
        Snacks.profiler.scratch()
      end,
      desc = "Profiler Scratch Bufer",
    },
    {
      "<C-f>",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>b",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>lc",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find in Config",
    },
    {
      "<leader>lC",
      function()
        Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
      end,
      desc = "Find in Plugnss",
    },
    {
      "<leader>ld",
      function()
        Snacks.picker.files({ cwd = "~/Downloads/" })
      end,
      desc = "Find in Downloads",
    },
    {
      "<leader>n",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Find Git Files",
    },
    {
      "<leader>N",
      function()
        Snacks.picker.git_files({ untracked = true })
      end,
      desc = "Find Untracked Git Files",
    },
    {
      "<C-p>",
      function()
        Snacks.picker.projects({
          finder = "recent_projects",
          format = "file",
          dev = { "~/repos", "~/.config", "~/repos_personal" },
          patterns = {
            "ruleset2.0.yaml",
            ".git",
            ".gitignore",
            ".hg",
            ".bzr",
            ".svn",
            "package.json",
            "Makefile",
          },
          confirm = "load_session",
          recent = true,
          matcher = {
            frecency = true, -- use frecency boosting
            sort_empty = true, -- sort even when the filter is empty
            cwd_bonus = false,
          },
          sort = { fields = { "score:desc", "idx" } },
          win = {
            preview = { minimal = true },
            input = {
              keys = {
                ["<c-f>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
                ["<CR>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
                ["<c-g>"] = { { "tcd", "picker_grep" }, mode = { "n", "i" } },
                ["<c-r>"] = { { "tcd", "picker_recent" }, mode = { "n", "i" } },
                ["<c-w>"] = { { "tcd" }, mode = { "n", "i" } },
                ["<c-t>"] = {
                  function(picker)
                    vim.cmd("tabnew")
                    Snacks.notify("New tab opened")
                    picker:close()
                    Snacks.picker.projects()
                  end,
                  mode = { "n", "i" },
                },
              },
            },
          },
        })
      end,
      desc = "Projects",
    },
    {
      "<leader>r",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Log File",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Visual selection or word",
      mode = { "n", "x" },
    },
    {
      "<leader><leader>",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Grep Selection",
      mode = { "v" },
    },
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = "Registers",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "Help Pages",
    },
    {
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Highlights",
    },
    {
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "Jumps",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      desc = "Location List",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Undo History",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
  },
}
