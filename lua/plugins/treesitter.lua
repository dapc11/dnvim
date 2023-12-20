local function large_file(_, bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 5000
end
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync" },
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
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "yaml",
      },
      playground = { enable = false },
      textobjects = {
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
            ["ip"] = "@parameter.inner",
            ["ap"] = "@parameter.outer",
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

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.gotmpl = {
        install_info = {
          url = "https://github.com/ngalaiko/tree-sitter-go-template",
          files = { "src/parser.c" },
        },
        filetype = "gotmpl",
        used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml", "tpl", "yml" },
      }

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
