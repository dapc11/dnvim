local M = {}

local packer_status_ok, packer = pcall(require, "packer")
if not packer_status_ok then
  return
end

packer.startup({
  function(use)
    use({ "wbthomason/packer.nvim" })
    use({ "lewis6991/impatient.nvim" })

    use({ "nvim-lua/plenary.nvim" })
    use({ "nvim-lua/popup.nvim" })
    use({ "tpope/vim-unimpaired" })
    use({ "dapc11/vim-fugitive" })

    use({
      "lewis6991/gitsigns.nvim",
      config = function()
        require("configs.gitsigns").config()
      end,
    })
    use({
      "nvim-treesitter/nvim-treesitter",
      requires = {
        "mfussenegger/nvim-ts-hint-textobject",
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      config = function()
        require("configs.treesitter").config()
      end,
      run = ":TSUpdate",
    })

    use({
      "fatih/vim-go",
      run = ":GoUpdateBinaries",
      ft = { "go" },
    })

    use({
      "nvim-telescope/telescope.nvim",
      requires = {
        { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
      },
      config = function()
        require("configs.telescope").config()
      end,
    })
    use({
      "phaazon/hop.nvim",
      branch = "v1",
      disable = not _G.plugins.hop,
      config = function()
        require("configs.hop").config()
      end,
    })

    use({
      "L3MON4D3/LuaSnip",
      config = function()
        require("configs.luasnip").config()
      end,
    })

    use({ "rafamadriz/friendly-snippets" })
    use({
      "hrsh7th/nvim-cmp",
      after = "LuaSnip",
      requires = {
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
      },
      config = function()
        require("configs.nvim_cmp").config()
      end,
    })
    use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
    use({
      "williamboman/mason-lspconfig.nvim",
      requires = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
      },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup()
        local status_ok, lspconfig = pcall(require, "lspconfig")
        if not status_ok then
          return
        end
        local win = require("lspconfig.ui.windows")
        local lsputils = require("configs.lsp.utils")
        local util = require("lspconfig/util")
        local _default_opts = win.default_opts

        win.default_opts = function(options)
          local opts = _default_opts(options)
          opts.border = "single"
          return opts
        end
        lsputils.lsp_handlers()

        local on_attach = function(client, bufnr)
          lsputils.lsp_keymaps(bufnr)
          lsputils.lsp_highlight_document(client)
          client.resolved_capabilities.document_formatting = false
          client.resolved_capabilities.document_range_formatting = false
        end
        require("mason-lspconfig").setup_handlers({
          -- The first entry (without a key) will be the default handler
          -- and will be called for each installed server that doesn't have
          -- a dedicated handler.
          function(server_name) -- default handler (optional)
            lspconfig[server_name].setup({
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
            })
          end,
          ["yamlls"] = function()
            lspconfig.yamlls.setup({
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              filetypes = { "yaml", "tpl", "gotmpl" },
              settings = {
                yaml = {},
              },
            })
          end,
          ["jdtls"] = function()
            local bundles = {
              vim.fn.glob(
                os.getenv("HOME")
                  .. "/dev/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
              ),
            }
            vim.list_extend(
              bundles,
              vim.split(vim.fn.glob(os.getenv("HOME") .. "/dev/vscode-java-test/server/*.jar"), "\n")
            )

            lspconfig.jdtls.setup({
              cmd = {
                'JAR="$HOME/.local/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"',
                "java ",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xms1g",
                "-Xmx2G",
                '-jar $(echo "$JAR")',
                '-configuration "$HOME/.local/jdtls/config_linux"',
                "--add-modules=ALL-SYSTEM",
                "--add-opens java.base/java.util=ALL-UNNAMED",
                "--add-opens java.base/java.lang=ALL-UNNAMED",
                -- "-Xbootclasspath/a:$HOME/.config/nvim/dependencies/lombok.jar",
                -- "-javaagent:$HOME/.config/nvim/dependencies/lombok.jar",
                -- '-data "$1"',
              },
              root_dir = function(fname)
                return util.root_pattern(".git", "pom.xml")(fname) or util.path.dirname(fname)
              end,
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              settings = {
                java = {
                  signatureHelp = { enabled = true },
                  completion = {
                    favoriteStaticMembers = {
                      "org.hamcrest.MatcherAssert.assertThat",
                      "org.hamcrest.Matchers.*",
                      "org.hamcrest.CoreMatchers.*",
                      "org.junit.jupiter.api.Assertions.*",
                      "java.util.Objects.requireNonNull",
                      "java.util.Objects.requireNonNullElse",
                      "org.mockito.Mockito.*",
                    },
                  },
                  sources = {
                    organizeImports = {
                      starThreshold = 9999,
                      staticStarThreshold = 9999,
                    },
                  },
                  codeGeneration = {
                    toString = {
                      template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                  },
                },
              },
            })
          end,
          ["pyright"] = function()
            lspconfig.pyright.setup({
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "off",
                    autoImportCompletions = true,
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = false,
                    diagnosticMode = "openFilesOnly",
                  },
                },
              },
              root_dir = function(fname)
                return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
                  or util.path.dirname(fname)
              end,
            })
          end,
          ["gopls"] = function()
            lspconfig.gopls.setup({
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              settings = {
                gopls = {
                  analyses = {
                    unusedparams = true,
                  },
                  completeUnimported = true,
                  staticcheck = true,
                  buildFlags = { "-tags=integration,e2e" },
                  hoverKind = "FullDocumentation",
                  linkTarget = "pkg.go.dev",
                  linksInHover = true,
                  experimentalWorkspaceModule = true,
                  experimentalPostfixCompletions = true,
                  codelenses = {
                    generate = true,
                    gc_details = true,
                    test = true,
                    tidy = true,
                  },
                  usePlaceholders = true,

                  completionDocumentation = true,
                  deepCompletion = true,
                },
              },
            })
          end,
          ["golangci_lint_ls"] = function() end,
          ["lua-language-server"] = function()
            local sumneko_binary_path = vim.fn.expand("$HOME")
              .. "/software/lua-language-server/bin/lua-language-server"
            local sumneko_root_path = vim.fn.expand("$HOME") .. "/software/lua-language-server/"

            local runtime_path = vim.split(package.path, ";")
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")

            lspconfig.sumneko_lua.setup({
              cmd = { sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" },
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              settings = {
                Lua = {
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim", "plugins" },
                  },
                  runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "Lua 5.3",
                    -- Setup your lua path
                    path = {
                      "?.lua",
                      "?/init.lua",
                      vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
                      vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
                      "/usr/share/5.3/?.lua",
                      "/usr/share/lua/5.3/?/init.lua",
                    },
                  },
                  workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = {
                      vim.fn.expand("~/.luarocks/share/lua/5.3"),
                      "/usr/share/lua/5.3",
                    },
                    ignoreDir = { ".git" },
                    maxPreload = 100000,
                    preloadFileSize = 10000,
                  },
                  -- Do not send telemetry data containing a randomized but unique identifier
                  telemetry = {
                    enable = false,
                  },
                },
              },
            })
          end,
        })
      end,
    })

    use({
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require("configs.lsp.nullls").config()
      end,
    })

    use({
      "lukas-reineke/indent-blankline.nvim",
      event = "BufRead",
      config = function()
        require("configs.indent_blankline").config()
      end,
    })

    use({
      "j-hui/fidget.nvim",
      config = function()
        require("fidget").setup()
      end,
    })
    use({
      "nvim-lualine/lualine.nvim",
      after = "nvim-web-devicons",
      config = function()
        require("configs.lualine").config()
      end,
    })

    use({
      "norcalli/nvim-colorizer.lua",
      ft = { "text", "json", "yaml", "css", "html", "lua", "vim" },
      config = function()
        require("configs.colorizer").config()
      end,
    })

    use({
      "kyazdani42/nvim-web-devicons",
      event = "BufRead",
    })

    use({ "ellisonleao/gruvbox.nvim" })
    use({ "dapc11/onedark.nvim" })
    use({ "catppuccin/nvim", as = "catppuccin" })

    use({
      "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons", -- optional, for file icons
      },
      config = function()
        require("configs.nvim_tree").config()
      end,
    })

    use({
      "terrortylor/nvim-comment",
      config = function()
        require("configs.nvim_comment").config()
      end,
    })

    use({
      "dapc11/project.nvim",
      config = function()
        require("configs.project_nvim").config()
      end,
    })

    use({ "ThePrimeagen/harpoon" })
    use({
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("configs.autopairs").config()
      end,
    })
    use({
      "kylechui/nvim-surround",
      config = function()
        require("configs.nvim-surround").config()
      end,
    })
    use({ "junegunn/vim-easy-align" })
    use({ "folke/lua-dev.nvim" })
    use({
      "folke/which-key.nvim",
      config = function()
        require("configs.which-key").config()
      end,
    })
    use({
      "ThePrimeagen/refactoring.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        { "nvim-telescope/telescope.nvim" },
      },
      config = function()
        require("configs.refactoring").config()
      end,
    })
    use("leoluz/nvim-dap-go")
    use({
      "nvim-neotest/neotest",
      requires = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-neotest/neotest-python",
        "nvim-neotest/neotest-go",
      },
      config = function()
        require("neotest").setup({
          adapters = {
            require("neotest-python")({
              dap = { justMyCode = false },
              runner = "pytest",
              python = "/usr/bin/python3",
            }),
            require("neotest-go"),
          },
        })
      end,
    })
    use({
      "mfussenegger/nvim-dap",
      -- event = "BufWinEnter",
      after = "nvim-dap-ui",
      config = function()
        require("configs.dap").setup()
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end,
    })

    use({
      "rcarriga/nvim-dap-ui",
      config = function()
        require("dapui").setup({
          icons = { expanded = "▾", collapsed = "▸" },
          mappings = {
            -- Use a table to apply multiple mappings
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
          },
          -- Expand lines larger than the window
          -- Requires >= 0.7
          expand_lines = vim.fn.has("nvim-0.7"),
          layouts = {
            {
              elements = {
                "scopes",
                "breakpoints",
                "stacks",
                "watches",
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                "repl",
                "console",
              },
              size = 10,
              position = "bottom",
            },
          },
          windows = { indent = 1 },
          render = {
            max_type_length = nil, -- Can be integer or nil.
          },
        })
      end,
      requires = { "mfussenegger/nvim-dap" },
    })

    use({
      "theHamsta/nvim-dap-virtual-text",
      requires = { "mfussenegger/nvim-dap" },
      config = function()
        require("nvim-dap-virtual-text").setup()
      end,
    })
    use({
      "iamcco/markdown-preview.nvim",
      run = function()
        vim.fn["mkdp#util#install"]()
      end,
      ft = "markdown",
      cmd = { "MarkdownPreview" },
    })
    use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
    use({
      "akinsho/toggleterm.nvim",
      config = function()
        require("configs.toggleterm").config()
      end,
    })
    use({
      "tversteeg/registers.nvim",
    })
  end,
  config = {
    compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua",
    profile = {
      enable = true,
      threshold = 0.0001,
    },
    git = {
      clone_timeout = 300,
    },
    auto_clean = true,
    compile_on_sync = true,
  },
})

return M
