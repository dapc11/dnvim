local load_textobjects = false
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/playground",
      "RRethy/nvim-treesitter-textsubjects",
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          load_textobjects = true
        end,
      },
    },
    cmd = { "TSUpdateSync" },
    opts = {
      textsubjects = {
        enable = true,
        prev_selection = ",", -- (Optional) keymap to select the previous selection
        keymaps = {
          ["."] = "textsubjects-smart",
          [";"] = "textsubjects-container-outer",
          ["i;"] = "textsubjects-container-inner",
        },
      },
      highlight = {
        enable = false,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
      },
      indent = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 2000
        end,
      },
      ensure_installed = {
        "bash",
        "c",
        "html",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "vim",
        "yaml",
      },
      playground = { enable = false },
      -- tree_docs = { enable = true }, lacks python support
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
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
      },
      incremental_selection = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
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

      if load_textobjects then
        -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              local Loader = require("lazy.core.loader")
              Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
              local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
              require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
              break
            end
          end
        end
      end
    end,
  },
}
