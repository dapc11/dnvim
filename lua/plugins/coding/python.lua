return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "ninja", "python", "rst", "toml" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            local root_files = {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "manage.py",
              "pyrightconfig.json",
            }
            return util.root_pattern(unpack(root_files))(fname)
              or util.root_pattern(".git")(fname)
              or util.path.dirname(fname)
          end,
          settings = {
            pyright = {
              disableLanguageServices = false,
              disableOrganizeImports = false,
            },
            python = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportMissingImports = "none",
                  reportOptionalMemberAccess = "none",
                },
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
          single_file_support = true,
        },
        ruff_lsp = {},
      },
      setup = {
        ruff_lsp = function()
          require("lazyvim.util").on_attach(function(client, _)
            if client.name == "ruff_lsp" then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = {
            justMyCode = false,
            console = "integratedTerminal",
          },
          args = { "--log-level", "DEBUG", "--quiet", "-vvv" },
          runner = "pytest",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      config = function()
        pcall(function()
          local path = require("mason-registry").get_package("debugpy"):get_install_path()
          require("dap-python").setup(path .. "/venv/bin/python")
        end)
      end,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {},
  },
}
