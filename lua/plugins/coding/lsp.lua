vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    severity_sort = true,
  })

-- diagnostics icons
for name, icon in pairs(require("config.icons").icons.diagnostics) do
  name = "DiagnosticSign" .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function(_, _)
      local on_attach = function(_, bufnr)
        local lopts = { buffer = bufnr, noremap = true, silent = true }
        local function get_opts(desc)
          local description = desc or ""
          return vim.tbl_deep_extend("force", lopts, { desc = description })
        end

          -- stylua: ignore start
          vim.keymap.set( "n", "<C-e>", vim.diagnostic.open_float, lopts)
          vim.keymap.set( "n", "gD", vim.lsp.buf.declaration, get_opts("Goto declaration"))
          vim.keymap.set( "n", "gd", vim.lsp.buf.definition, get_opts("Goto definition"))
          vim.keymap.set( "n", "gr", vim.lsp.buf.references, get_opts("Goto references"))
          vim.keymap.set( "n", "gi", vim.lsp.buf.implementation, get_opts())
          vim.keymap.set( "n", "K", vim.lsp.buf.hover, get_opts())
          vim.keymap.set( "n", "<C-k>", vim.lsp.buf.signature_help, get_opts())
          vim.keymap.set( "n", "<leader>cwa", vim.lsp.buf.add_workspace_folder, get_opts("Add workspace folder"))
          vim.keymap.set( "n", "<leader>cwr", vim.lsp.buf.remove_workspace_folder, get_opts("Remove workspace folder"))
          vim.keymap.set( "n", "<leader>cwl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, get_opts("List workspace folders"))
          vim.keymap.set( "n", "<leader>cr", vim.lsp.buf.rename, get_opts("Rename"))
          vim.keymap.set( { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, get_opts("Code actions"))
          vim.keymap.set( "n", ">d", vim.diagnostic.goto_prev, get_opts())
          vim.keymap.set( "n", "<d", vim.diagnostic.goto_next, get_opts())
          if vim.bo.filetype ~= "lua" then
            vim.keymap.set( "n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, get_opts("Format"))
          end
        -- stylua: ignore end
      end

      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup({
        on_attach = on_attach,
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
      })
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
              maxPreload = 10000,
              preloadFileSize = 1000,
            },
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "jit", "vim", "lvim", "reload" },
            },
          },
        },
      })
      lspconfig.gopls.setup({
        on_attach = on_attach,
        settings = {
          gopls = {
            gofumpt = false,
            codelenses = {
              gc_details = false,
              generate = false,
              regenerate_cgo = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            diagnosticsDelay = "300ms",
            symbolMatcher = "fuzzy",
            completeUnimported = true,
            staticcheck = false,
            matcher = "Fuzzy",
            usePlaceholders = true,
            analyses = {
              fieldalignment = true,
              nilness = true,
              shadow = true,
              unusedparams = true,
              unusedwrite = true,
            },
          },
        },
      })
    end,
  },
}
