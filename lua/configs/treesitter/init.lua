local M = {}

function M.config()
  local treesitter = require("nvim-treesitter.configs")
  require("tsht").config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

  local disable_large_files = function(_, bufnr)
    return vim.api.nvim_buf_line_count(bufnr) > 2000
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
    indent = { enable = true, disable = { "yaml" } },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["at"] = "@class.outer",
          ["it"] = "@class.inner",
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ai"] = "@conditional.outer",
          ["ii"] = "@conditional.inner",
          ["a/"] = "@comment.outer",
          ["i/"] = "@comment.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["as"] = "@statement.outer",
          ["is"] = "@scopename.inner",
          ["aA"] = "@attribute.outer",
          ["iA"] = "@attribute.inner",
          ["aF"] = "@frame.outer",
          ["iF"] = "@frame.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["<m"] = "@function.outer",
          ["<<"] = "@class.outer",
        },
        goto_next_end = {
          ["<M"] = "@function.outer",
          ["<>"] = "@class.outer",
        },
        goto_previous_start = {
          [">m"] = "@function.outer",
          [">>"] = "@class.outer",
        },
        goto_previous_end = {
          [">M"] = "@function.outer",
          ["><"] = "@class.outer",
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
