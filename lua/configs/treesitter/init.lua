local M = {}

function M.config()
  local treesitter = require("nvim-treesitter.configs")
  require("tsht").config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

  local disable_large_files = function(_, bufnr)
    return vim.api.nvim_buf_line_count(bufnr) > 1000
  end

  parser_config.gotmpl = {
    install_info = {
      url = "https://github.com/ngalaiko/tree-sitter-go-template",
      files = { "src/parser.c" },
    },
    filetype = "gotmpl",
    used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml", "tpl", "yml" },
  }
  treesitter.setup({
    ensure_installed = {
      "python",
      "lua",
      "dockerfile",
      "json",
      "yaml",
      "css",
      "html",
      "go",
      "bash",
      "java",
      "vim",
      "toml",
      "markdown",
      "comment",
    },
    highlight = {
      enable = true,
      disable = disable_large_files,
      -- additional_vim_regex_highlighting = { "python" }
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "<C-w>",
        scope_incremental = "grc",
        node_decremental = "<A-w>",
      },
    },
    indent = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    },
    pairs = {
      enable = true,
      disable = {},
      goto_right_end = false, -- whether to go to the end of the right partner or the beginning
      fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
      keymaps = { goto_partner = "<leader>%" }, -- do not work
    },
  })
end

return M
