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

    use({
      "liuchengxu/vista.vim",
      cmd = "Vista",
      config = function()
        require("configs.vista")
      end,
    })
    use({ "rafamadriz/friendly-snippets" })
    use({
      "hrsh7th/nvim-cmp",
      after = "LuaSnip",
      requires = {
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
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
      "ray-x/lsp_signature.nvim",
      after = "cmp-nvim-lsp",
      config = function()
        require("lsp_signature").setup({
          bind = true,
          doc_lines = 0,
          floating_window = true,
          fix_pos = true,
          hint_enable = true,
          hint_prefix = " ",
          hint_scheme = "string",
          hi_parameter = "search",
          max_height = 22,
          max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
          handler_opts = {
            border = "single", -- double, single, shadow, none
          },
          zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
          padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
        })
      end,
    })
    use({
      "seblj/nvim-echo-diagnostics",
      config = function()
        require("echo-diagnostics").setup({
          show_diagnostic_number = true,
          show_diagnostic_source = true,
        })
        vim.cmd([[
            autocmd CursorHold * lua require('echo-diagnostics').echo_line_diagnostic()
        ]])
      end,
    })
    use({
      "neovim/nvim-lspconfig",
      after = "lsp_signature.nvim",
      config = function()
        require("configs.lsp.lsp").config()
      end,
    })

    use({
      "jose-elias-alvarez/null-ls.nvim",
      after = "lsp_signature.nvim",
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

    use({
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("configs.neo_tree").config()
      end,
    })

    use({
      "akinsho/toggleterm.nvim",
      config = function()
        require("configs.toggleterm").config()
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
    use({
      "ur4ltz/surround.nvim",
      config = function()
        require("configs.surround").config()
      end,
    })
    use("leoluz/nvim-dap-go")
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
          sidebar = {
            -- You can change the order of elements in the sidebar
            elements = {
              -- Provide as ID strings or tables with "id" and "size" keys
              {
                id = "scopes",
                size = 0.50, -- Can be float or integer > 1
              },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.15 },
              { id = "watches", size = 0.10 },
            },
            size = 60,
            position = "left", -- Can be "left", "right", "top", "bottom"
          },
          tray = {
            elements = { "repl" },
            size = 10,
            position = "bottom", -- Can be "left", "right", "top", "bottom"
          },
          floating = {
            max_height = nil, -- These can be integers or a float between 0 and 1.
            max_width = nil, -- Floats will be treated as percentage of your screen.
            border = "single", -- Border style. Can be "single", "double" or "rounded"
            mappings = {
              close = { "q", "<Esc>" },
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
    use({ "rhysd/vim-grammarous" })
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
