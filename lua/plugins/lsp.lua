local function readlines(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end

  local lines = {}

  for line in io.lines(path) do
    table.insert(lines, line)
  end

  file:close()
  return lines
end

local function writeLines(packages, path)
  local file = io.open(path, "w")
  if not file then
    return nil
  end
  for _, package in ipairs(packages) do
    file:write(package .. "\n")
  end
  file:close()
end

return {
  {
    "neovim/nvim-lspconfig",
    event = lazyfile,
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local lsp = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local function setup(lsp_name)
        -- Argument shul be same as handler key.
        local success, conf = pcall(require, "plugins.language_servers." .. lsp_name)
        if not success then
          conf = {}
        end
        return function()
          lsp[lsp_name].setup(vim.tbl_deep_extend("force", conf, { capabilities = capabilities }))
        end
      end
      require("mason-lspconfig").setup({
        ensure_installed = { "jdtls", "helm_ls", "gopls", "lua_ls", "zk" }, -- zk@v0.13.0 due to depenency of glibc version > 2.31.0
        automatic_installation = false,
        handlers = {
          jdtls = noop,
          pyright = setup("pyright"),
          gopls = setup("gopls"),
          lua_ls = setup("lua_ls"),
          dockerls = setup("dockerls"),
          helm_ls = setup("helm_ls"),
          yamlls = setup("yamlls"),
        }
      })
      vim.diagnostic.config({
        virtual_text = true,
        underline = false,
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "lazy.nvim",
      },
    },
  },
  { "mfussenegger/nvim-jdtls", ft = "java" },
  {
    "saghen/blink.cmp",
    event = lazyfile,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "mikavilpas/blink-ripgrep.nvim",
      "Kaiser-Yang/blink-cmp-dictionary",
    },
    version = "0.13.1",
    opts = {
      keymap = { preset = "super-tab" },
      fuzzy = { implementation = "rust" },
      appearance = {
        use_nvim_cmp_as_default = true,
      },
      completion = {
        menu = {
          auto_show = function(ctx)
            return ctx.mode ~= "cmdline"
          end,
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", gap = 1, "kind" },
            },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
        per_filetype = {
          lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
          gitcommit = { "dictionary", "path", "snippets", "buffer", "ripgrep" },
          markdown = { "dictionary", "path", "snippets", "buffer", "ripgrep" },
        },
        providers = {
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            enabled = true,         -- Whether or not to enable the provider
            async = false,          -- Whether we should wait for the provider to return before showing the completions
            timeout_ms = 2000,      -- How long to wait for the provider to return before showing completions and treating it as asynchronous
            min_keyword_length = 2, -- Minimum number of characters in the keyword to trigger the provider
          },
          dictionary = {
            module = "blink-cmp-dictionary",
            name = "Dict",
            min_keyword_length = 3,
            max_items = 5,
            opts = {
              dictionary_files = nil,
              dictionary_directories = nil,
              get_command = "rg",
              get_command_args = function(prefix, _)
                return {
                  "--color=never",
                  "--no-line-number",
                  "--no-messages",
                  "--no-filename",
                  "--smart-case",
                  "--",
                  prefix,
                  vim.fn.stdpath("config") .. "/words.txt",
                }
              end
            },
          }
        },
      }
    },
    opts_extend = { "sources.default" },
  },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      require("nvim-goc").setup(opts)
    end,
  },
  {
    "fredrikaverpil/godoc.nvim",
    event = lazyfile,
    version = "2.x",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        {

          command = "PyDoc",
          get_items = function()
            local function split_by_whitespace(input_str)
              local result = {}
              for match in input_str:gmatch("%S+") do
                table.insert(result, match)
              end
              return result
            end

            local packages = {}
            local cache_file = vim.fn.stdpath("data") .. "/pydoc_cache.txt"

            -- Check if the cache_file already exists, if exists, return cached packages
            if vim.loop.fs_stat(cache_file) then
              return readlines(cache_file)
            end

            local std_packages = vim.fn.systemlist("python3 -c 'help(\"modules\")'")
            -- Filter out the first few lines which are not actual package names.
            for index, value in ipairs(std_packages) do
              if index > 11 and index < #std_packages - 2 then
                for _, package in ipairs(split_by_whitespace(value)) do
                  table.insert(packages, package)
                end
              end
            end

            table.sort(packages)

            -- Cache packages list
            writeLines(packages, cache_file)
            return packages
          end,
          get_content = function(choice)
            return vim.fn.systemlist("python3 -m pydoc " .. choice)
          end,
          get_syntax_info = function()
            return {
              filetype = "pydoc",
              language = "python",
            }
          end,
        },
      },
    },
  },
}
