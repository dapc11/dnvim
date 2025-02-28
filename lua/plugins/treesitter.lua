local function large_file(_, bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 5000
end
return {
  {
    "ThePrimeagen/refactoring.nvim",
    event = lazyfile,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>ce", ":Refactor extract ", mode = "x" },
      { "<leader>cf", ":Refactor extract_to_file ", mode = "x" },
      { "<leader>cv", ":Refactor extract_var ", mode = "x" },
      { "<leader>ci", ":Refactor inline_var", mode = { "n", "x" } },
      { "<leader>cI", ":Refactor inline_func" },
      { "<leader>cb", ":Refactor extract_block" },
      { "<leader>cbf", ":Refactor extract_block_to_file" },
    },
    config = function()
      require("refactoring").setup({})
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
          init_selection = "<A-right>",
          node_incremental = "<A-right>",
          node_decremental = "<A-left>",
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
            ["l"] = "@assignment.lhs",
            ["r"] = "@assignment.rhs",
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
