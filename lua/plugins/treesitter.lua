local function large_file(_, bufnr)
  local MAX_LINES_FOR_TREESITTER = 5000 -- Disable treesitter for large files
  return vim.api.nvim_buf_line_count(bufnr) > MAX_LINES_FOR_TREESITTER
end
return {
  {
    "aaronik/treewalker.nvim",
    opts = {
      highlight = true,
      highlight_duration = 250, -- Highlight duration in milliseconds
      highlight_group = "CursorLineNr",
    },
    config = function(_, opts)
      require("treewalker").setup(opts)

      vim.keymap.set({ "n", "v" }, "<C-up>", "<cmd>Treewalker Up<cr>", { silent = true })
      vim.keymap.set({ "n", "v" }, "<C-down>", "<cmd>Treewalker Down<cr>", { silent = true })
      vim.keymap.set("n", "<C-S-up>", "<cmd>Treewalker SwapUp<cr>", { silent = true })
      vim.keymap.set("n", "<C-S-down>", "<cmd>Treewalker SwapDown<cr>", { silent = true })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = lazyfile,
    cmd = "TSUpdateSync",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = lazyfile,
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
    },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<S-A-right>",
          node_incremental = "<S-A-right>",
          node_decremental = "<S-A-left>",
        },
      },
      highlight = {
        enable = true,
        disable = large_file,
      },
      indent = {
        enable = true,
        disable = large_file,
      },
      ensure_installed = {
        "bash",
        "json",
        "java",
        "lua",
        "go",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "yaml",
      },
      playground = { enable = true },
      textobjects = {
        lsp_interop = {
          enable = true,
          floating_preview_opts = {},
          peek_definition_code = {
            ["<leader>cm"] = "@function.outer",
            ["<leader>cM"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<C-l>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<C-h>"] = "@parameter.inner",
          },
        },
        select = {
          disable = { "yaml" },
          enable = true,
          lookahead = true,
          keymaps = {
            ["aa"] = "@assignment.outer",
            ["ia"] = "@assignment.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["aC"] = "@class.outer",
            ["ir"] = "@return.inner",
            ["ar"] = "@return.outer",
            ["il"] = "@loop.inner",
            ["al"] = "@loop.outer",
            ["iP"] = "@parameter.inner",
            ["aP"] = "@parameter.outer",
            ["ib"] = "@block.inner",
            ["ab"] = "@block.outer",
            ["ic"] = "@conditional.inner",
            ["ac"] = "@conditional.outer",
            ["iC"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          },
          include_surrounding_whitespace = true,
        },
        disable = large_file,
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
