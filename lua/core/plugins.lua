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
      "neovim/nvim-lspconfig",
      config = function()
        require("configs.lsp.lsp").config()
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
      "plasticboy/vim-markdown",
      requires = "godlygeek/tabular",
      ft = "markdown",
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
