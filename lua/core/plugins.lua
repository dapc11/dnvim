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
      branch = "v2",
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

    use("hrsh7th/cmp-buffer") -- buffer completions
    use("hrsh7th/cmp-path") -- path completions
    use("hrsh7th/cmp-cmdline") -- cmdline completions
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-nvim-lua")
    use({ "rafamadriz/friendly-snippets" })
    use({
      "hrsh7th/nvim-cmp",
      after = "LuaSnip",
      config = function()
        require("configs.nvim_cmp").config()
      end,
    })
    use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
    use("mfussenegger/nvim-jdtls")
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
        local util = require("lspconfig.util")
        local _default_opts = win.default_opts

        win.default_opts = function(options)
          local opts = _default_opts(options)
          opts.border = "rounded"
          return opts
        end
        lsputils.lsp_handlers()

        local on_attach = function(client, bufnr)
          lsputils.lsp_keymaps(bufnr)
          lsputils.attach_navic(client, bufnr)
          lsputils.lsp_highlight_document(client, bufnr)
          client.server_capabilities.formatting = false
          client.server_capabilities.range_formatting = false
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
          ["sumneko_lua"] = function()
            lspconfig.sumneko_lua.setup({
              on_attach = on_attach,
              capabilities = lsputils.capabilities,
              flags = lsputils.flags,
              settings = {
                Lua = {
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim", "plugins" },
                  },
                  workspace = {
                    ignoreDir = { ".git" },
                    maxPreload = 100000,
                    preloadFileSize = 10000,
                    library = {
                      [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                      [vim.fn.stdpath("config") .. "/lua"] = true,
                      -- [vim.fn.datapath "config" .. "/lua"] = true,
                    },
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
      "NvChad/nvim-colorizer.lua",
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
    use({
      "catppuccin/nvim",
      as = "catppuccin",
    })
    use({ "folke/tokyonight.nvim" })

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
    use({
      "akinsho/toggleterm.nvim",
      config = function()
        require("configs.toggleterm").config()
      end,
    })
    use({
      "tversteeg/registers.nvim",
    })
    use({
      "mfussenegger/nvim-treehopper",
      config = function()
        vim.cmd([[
          omap <silent> m :<C-U>lua require('tsht').nodes()<CR>
          xnoremap <silent> m :lua require('tsht').nodes()<CR>
        ]])
      end,
    })
    use({
      "SmiteshP/nvim-navic",
      config = function()
        require("nvim-navic").setup({
          highlight = true,
        })
      end,
      requires = "neovim/nvim-lspconfig",
    })
    use({
      "karb94/neoscroll.nvim",
      config = function()
        require("neoscroll").setup({
          -- All these keys will be mapped to their corresponding default scrolling animation
          mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
          hide_cursor = true, -- Hide cursor while scrolling
          stop_eof = true, -- Stop at <EOF> when scrolling downwards
          respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
          cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
          easing_function = nil, -- Default easing function
          pre_hook = nil, -- Function to run before the scrolling animation starts
          post_hook = nil, -- Function to run after the scrolling animation ends
          performance_mode = false, -- Disable "Performance Mode" on all buffers.
        })
      end,
    })
    use({
      "RRethy/vim-illuminate",
      config = function()
        _G.plugins.illuminate = true

        require("illuminate").configure({
          -- providers: provider used to get references in the buffer, ordered by priority
          providers = {
            "lsp",
            "treesitter",
            "regex",
          },
          -- delay: delay in milliseconds
          delay = 120,
          -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
          filetypes_denylist = {
            "dirvish",
            "fugitive",
            "alpha",
            "NvimTree",
            "packer",
            "neogitstatus",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "TelescopePrompt",
          },
          -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
          filetypes_allowlist = {},
          -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
          modes_denylist = {},
          -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
          modes_allowlist = {},
          -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
          -- Only applies to the 'regex' provider
          -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
          providers_regex_syntax_denylist = {},
          -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
          -- Only applies to the 'regex' provider
          -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
          providers_regex_syntax_allowlist = {},
          -- under_cursor: whether or not to illuminate under the cursor
          under_cursor = true,
        })
      end,
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
