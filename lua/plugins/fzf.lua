local function dropdown(...)
  return vim.tbl_deep_extend("force", {
    winopts = {
      height = 0.60,
      width = 0.50,
      fullscreen = false,
      preview = { layout = "flex" },
    },
  }, ...)
end

return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-telescope/telescope.nvim" },
    lazy = false,
    opts = function()
      local actions = require("fzf-lua").actions
      return {
        "max-perf",
        fzf_opts = { ["--layout"] = "reverse" },
        winopts = {
          fullscreen = true,
          preview = {
            default = "bat",
            flip_columns = 200,
            scrollbar = "border",
          },
        },
        fzf_colors = {
          ["fg"] = { "fg", "CursorLine" },
          ["bg+"] = { "bg", "CursorLine" },
          ["gutter"] = { "bg", "Normal" },
        },
        previewers = {
          bat = {
            theme = "base16",
          },
          git = {
            cmd = "git ls-files --exclude-standard --cached",
          },
        },
        keymap = {
          builtin = {
            ["<C-h>"] = "toggle-help",
          },
          fzf = {
            ["alt-a"] = "toggle-all",
            ["ctrl-p"] = "toggle-preview",
            ["shift-down"] = "preview-page-down",
            ["shift-up"] = "preview-page-up",
          },
        },
        actions = {
          files = {
            ["default"] = actions.file_edit_or_qf,
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-t"] = actions.file_tabedit,
            ["alt-q"] = actions.file_sel_to_qf,
            ["alt-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["ctrl-s"] = actions.buf_split,
            ["ctrl-v"] = actions.buf_vsplit,
            ["ctrl-t"] = actions.buf_tabedit,
          },
        },
        oldfiles = dropdown({
          winopts = {
            preview = { hidden = "hidden" },
          },
        }),
        files = dropdown({}),
        buffers = dropdown({
          winopts = {
            preview = { hidden = "hidden" },
          },
        }),
        keymaps = dropdown({}),
        grep = {
          no_header_i = true,
        },
        lsp = {
          symbols = {
            async_or_timeout = true,
            symbol_style = 1,
            symbol_icons = require("config.icons").icons.kinds,
          },
        },
      }
    end,
    keys = {
      { "<leader>r", "<cmd>FzfLua oldfiles cwd_only=false<CR>", desc = "Find Recent Files" },
      { "<leader>R", "<cmd>FzfLua oldfiles cwd_only=true<CR>", desc = "Find Recent Files In Cwd" },
      { "<leader>,", "<cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
      { "<leader>:", "<cmd>FzfLua command_history<CR>", desc = "Command History" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help" },
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
      { "<leader>gB", "<cmd>FzfLua git_branches<CR>", desc = "branches" },
      { "<leader>n", "<cmd>FzfLua git_files<CR>", desc = "Find Tracked Files" },
      {
        "<leader>N",
        function()
          require("fzf-lua").git_files({
            cmd = "git ls-files --modified --exclude-standard",
          })
        end,
        desc = "Find Untracked Files",
      },
      -- search
      { '<leader>s"', "<cmd>FzfLua registers<CR>", desc = "Registers" },
      { "<leader>sb", "<cmd>FzfLua lgrep_curbuf<CR>", desc = "Buffer" },
      {
        "<leader>sc",
        "<cmd>FzfLua command_history<CR>",
        desc = "Command History",
      },
      { "<leader>sC", "<cmd>FzfLua commands<CR>", desc = "Commands" },
      {
        "<leader>sd",
        "<cmd>FzfLua diagnostics_document<CR>",
        desc = "Document diagnostics",
      },
      {
        "<leader>sD",
        "<cmd>FzfLua diagnostics_workspace<CR>",
        desc = "Workspace diagnostics",
      },
      {
        "<leader>sg",
        "<cmd>FzfLua live_grep<CR>",
        desc = "Grep (root dir)",
      },
      {
        "<leader>sh",
        "<cmd>FzfLua highlights<CR>",
        desc = "Search Highlight Groups",
      },
      { "<leader>sk", "<cmd>FzfLua keymaps<CR>", desc = "Key Maps" },
      { "<leader>sR", "<cmd>FzfLua resume<CR>", desc = "Resume" },
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

      { "<leader><leader>", "<cmd>FzfLua grep_project<CR>", desc = "Live Grep" },
      { "<C-f>", "<cmd>FzfLua grep_curbuf<CR>", desc = "Find in Current Buffer" },
      {
        "<C-f>",
        function()
          require("fzf-lua").grep_visual()
        end,
        desc = "Current Buffer Grep Selection",
        mode = "v",
      },
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
