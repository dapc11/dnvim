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
    use({ "tpope/vim-fugitive" })
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
      keys = "<leader>vv",
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
    use({ "ray-x/lsp_signature.nvim", after = "cmp-nvim-lsp" })
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
    -- use({
    --   "dapc11/shade.nvim",
    --   config = function()
    --     require("configs.shade").config()
    --   end,
    -- })

    use({
      "mfussenegger/nvim-dap",
      -- event = "BufWinEnter",
      after = "nvim-dap-ui",
      config = function()
        require("configs.dap").setup()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()
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
    -- use({ "godlygeek/tabular" })
    -- use({ "preservim/vim-markdown", after = "tabular" })
    use({ "kevinhwang91/nvim-bqf", ft = "qf" })
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
