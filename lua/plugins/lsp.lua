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

local function writeLines(packages, file)
  local file = io.open(file, "w")
  if not file then
    return nil
  end
  for _, package in ipairs(packages) do
    file:write(package .. "\n")
  end
  file:close()
end

return {
  { "mfussenegger/nvim-jdtls", ft = "java" },
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "super-tab" },
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
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    lazy = true,
    events = _G.lazyfile,
    branch = "v3.x",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        dependencies = {
          { "williamboman/mason.nvim", events = _G.lazyfile },
          { "williamboman/mason-lspconfig.nvim", events = _G.lazyfile },
          { "saghen/blink.cmp", events = _G.lazyfile },
        },
        events = _G.lazyfile,
        config = function()
          local lsp_zero = require("lsp-zero")
          local lsp = require("lspconfig")
          local capabilities = require("blink.cmp").get_lsp_capabilities()
          local function setup(lsp_name)
            -- Argument shuld be same as handler key.
            local success, conf = pcall(require, "plugins.language_servers." .. lsp_name)
            if not success then
              conf = {}
            end
            return function()
              lsp[lsp_name].setup(
                vim.tbl_deep_extend("force", conf, { capabilities = capabilities })
              )
            end
          end

          require("mason").setup({})
          require("mason-lspconfig").setup({
            ensure_installed = { "jdtls", "helm_ls", "gopls", "lua_ls", "zk@v0.13.0" }, -- zk 0.13.0 due to depenency of glibc version > 2.31.0
            automatic_installation = false,
            handlers = {
              jdtls = noop,
              pyright = setup("pyright"),
              gopls = setup("gopls"),
              lua_ls = setup("lua_ls"),
              dockerls = setup("dockerls"),
              helm_ls = setup("helm_ls"),
              yamlls = setup("yamlls"),
            },
          })

          local icons = require("config.icons").icons

          lsp_zero.set_sign_icons({
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            hint = icons.diagnostics.Hint,
            info = icons.diagnostics.Info,
          })

          lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.highlight_symbol(client, bufnr)
            require("util").lsp_keymaps()
          end)

          lsp_zero.set_server_config({
            on_init = function(client)
              client.server_capabilities.semanticTokensProvider = nil
            end,
          })

          vim.diagnostic.config({
            virtual_text = true,
            underline = false,
          })
        end,
      },
    },
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
    version = "2.x",
    dependencies = {
      { "folke/snacks.nvim" },
      {
        "nvim-treesitter/nvim-treesitter",
        opts = {
          ensure_installed = { "go", "python" },
        },
      },
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
