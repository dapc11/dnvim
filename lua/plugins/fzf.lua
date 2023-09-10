local function dropdown(...)
  return vim.tbl_deep_extend("force", {
    fzf_opts = { ["--layout"] = "reverse" },
    winopts = {
      height = 0.90,
      width = 0.80,
      preview = { hidden = "nohidden", layout = "vertical" },
    },
  }, ...)
end

return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      "max-perf",
      fzf_opts = { ["--layout"] = "reverse" },
      winopts = { preview = { default = "builtin", layout = "vertical" } },
      fzf_colors = {
        ["fg"] = { "fg", "CursorLine" },
        ["bg"] = { "bg", "Normal" },
        ["hl"] = { "fg", "Comment" },
        ["fg+"] = { "fg", "Normal" },
        ["bg+"] = { "bg", "CursorLine" },
        ["hl+"] = { "fg", "Statement" },
        -- ["info"] = { "fg", "PreProc" },
        -- ["prompt"] = { "fg", "Conditional" },
        ["pointer"] = { "fg", "Exception" },
        ["marker"] = { "fg", "Keyword" },
        -- ["spinner"] = { "fg", "Label" },
        ["header"] = { "fg", "Comment" },
        ["gutter"] = { "bg", "Normal" },
      },
      keymap = {
        builtin = {
          ["<C-p>"] = "toggle-preview",
          ["<S-down>"] = "preview-page-down",
          ["<S-up>"] = "preview-page-up",
        },
        fzf = {
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
        },
      },
      oldfiles = dropdown({
        prompt = " History: ",
        cwd_only = true,
      }),
      files = dropdown({
        prompt = " Files: ",
      }),
      buffers = dropdown({
        prompt = "﬘ Buffers: ",
        winopts = {
          height = 0.60,
          width = 0.50,

          preview = { hidden = "hidden" },
        },
      }),
      keymaps = dropdown({
        prompt = " Keymaps: ",
        winopts = { width = 0.7 },
      }),
    },
    keys = {
      { "<leader>r", "<cmd>FzfLua oldfiles<cr>", desc = "Find Recent Files" },
      { "<leader>,", "<cmd>FzfLua buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help" },
      {
        "<leader>fp",
        function()
          require("fzf-lua").files({ cwd = require("lazy.core.config").options.root, prompt = "Plugin Files" })
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find Files (root dir)",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").files({
            cwd = "~/repos/",
            prompt = "Repos",
          })
        end,
        desc = "Find file in repos",
      },
      -- git
      { "<leader>gC", "<cmd>FzfLua git_commits<CR>", desc = "commits" },
      { "<leader>gS", "<cmd>FzfLua git_status<CR>", desc = "status" },
      { "<leader>gB", "<cmd>FzfLua git_branches<cr>", desc = "branches" },
      { "<leader>n", "<cmd>FzfLua git_files<cr>", desc = "Find Tracked Files" },
      {
        "<leader>N",
        function()
          require("fzf-lua").git_files({
            git_command = { "git", "ls-files", "--modified", "--exclude-standard" },
          })
        end,
        desc = "Find Untracked Files",
      },
      -- search
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>sb", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Buffer" },
      {
        "<leader>sc",
        "<cmd>FzfLua command_history<cr>",
        desc = "Command History",
      },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      {
        "<leader>sd",
        "<cmd>FzfLua diagnostics_document<cr>",
        desc = "Document diagnostics",
      },
      {
        "<leader>sD",
        "<cmd>FzfLua diagnostics_workspace<cr>",
        desc = "Workspace diagnostics",
      },
      {
        "<leader>sg",
        "<cmd>FzfLua live_grep<cr>",
        desc = "Grep (root dir)",
      },
      {
        "<leader>sh",
        "<cmd>FzfLua highlights<cr>",
        desc = "Search Highlight Groups",
      },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      {
        "<leader>sr",
        function()
          require("fzf-lua").live_grep({
            cwd = "~/repos/",
            path_display = { "truncate", shorten = { len = 1, exclude = { 1, -1 } } },
            prompt = "Repos",
          })
        end,
        desc = "Live grep in repos",
      },
      {
        "<leader>sw",
        function()
          require("fzf-lua").grep_visual()
        end,
        mode = "v",
        desc = "Selection (root dir)",
      },

      { "<leader><leader>", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
      { "<C-f>", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Find in Current Buffer" },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Goto Symbol",
      },
    },
  },
}
