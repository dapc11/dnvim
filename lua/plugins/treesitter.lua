local function large_file(_, bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 5000
end
return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = "TSUpdateSync",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
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
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "yaml",
    },
    playground = { enable = true },
    textobjects = {
      move = {
        enable = true,
        goto_next_start = { ["<f"] = "@function.outer", ["<c"] = "@class.outer" },
        goto_next_end = { ["<F"] = "@function.outer", ["<C"] = "@class.outer" },
        goto_previous_start = { [">f"] = "@function.outer", [">c"] = "@class.outer" },
        goto_previous_end = { [">F"] = "@function.outer", [">C"] = "@class.outer" },
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
}
