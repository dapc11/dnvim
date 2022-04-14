local M = {}

local packer_status_ok, packer = pcall(require, "packer")
if not packer_status_ok then
	return
end

packer.startup({
	function(use)
		use({ "wbthomason/packer.nvim" })
		use({ "lewis6991/impatient.nvim" })
		use({
			"nathom/filetype.nvim",
			config = function()
				vim.g.did_load_filetypes = 1
			end,
		})

		use({ "nvim-lua/plenary.nvim" })
		use({ "nvim-lua/popup.nvim" })

		use({ "tpope/vim-fugitive" })
		use({
			"lewis6991/gitsigns.nvim",
			config = function()
				require("configs.gitsigns")
			end,
		})
		use({
			"nvim-treesitter/nvim-treesitter",
			requires = {
				"mfussenegger/nvim-ts-hint-textobject",
				"nvim-treesitter/nvim-treesitter-textobjects",
			},
			config = function()
				require("configs.treesitter")
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
				require("configs.telescope")
			end,
		})
		use({
			"phaazon/hop.nvim",
			branch = "v1",
			config = function()
				require("hop").setup({ keys = "asdfgqwertzxcvb" })
			end,
		})

		use({ "rafamadriz/friendly-snippets" })
		use({
			"L3MON4D3/LuaSnip",
			after = "friendly-snippets",
			config = function()
				require("configs.luasnip")
			end,
		})
		use({
			"hrsh7th/nvim-cmp",
			after = "LuaSnip",
			config = function()
				require("configs.nvim_cmp")
			end,
		})
		use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
		use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
		use({ "ray-x/lsp_signature.nvim", after = "cmp-nvim-lsp" })
		use({
			"neovim/nvim-lspconfig",
			after = "lsp_signature.nvim",
			config = function()
				require("configs.lsp.lsp")
			end,
		})

		use({
			"jose-elias-alvarez/null-ls.nvim",
			after = "lsp_signature.nvim",
			config = function()
				require("configs.lsp.nullls")
			end,
		})

		use({
			"lukas-reineke/indent-blankline.nvim",
			event = "BufRead",
			config = function()
				require("configs.indent_blankline")
			end,
		})

		use({
			"nvim-lualine/lualine.nvim",
			after = "nvim-web-devicons",
			config = function()
				require("configs.lualine")
			end,
		})

		use({
			"norcalli/nvim-colorizer.lua",
			ft = { "json", "yaml", "css", "html", "lua", "vim" },
			config = function()
				require("configs.colorizer")
			end,
		})

		use({
			"kyazdani42/nvim-web-devicons",
			event = "BufRead",
		})

		use({ "ellisonleao/gruvbox.nvim" })
		use({ "navarasu/onedark.nvim" })

		use({
			"kyazdani42/nvim-tree.lua",
			config = function()
				require("configs.nvim_tree")
			end,
		})

		use({
			"akinsho/toggleterm.nvim",
			config = function()
				require("configs.toggleterm")
			end,
		})

		use({
			"terrortylor/nvim-comment",
			config = function()
				require("configs.nvim_comment")
			end,
		})

		use({
			"dapc11/project.nvim",
			config = function()
				require("project_nvim").setup({
					-- Manual mode doesn't automatically change your root directory, so you have
					-- the option to manually do so using `:ProjectRoot` command.
					manual_mode = false,

					-- Methods of detecting the root directory. **"lsp"** uses the native neovim
					-- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
					-- order matters: if one is not detected, the other is used as fallback. You
					-- can also delete or rearangne the detection methods.
					detection_methods = { "pattern" },

					-- All the patterns used to detect root dir, when **"pattern"** is in
					-- detection_methods
					patterns = {
						"ruleset2.0.yaml",
						"pom.xml",
						".git",
						"_darcs",
						".hg",
						".bzr",
						".svn",
						"Makefile",
						"package.json",
					},

					-- Table of lsp clients to ignore by name
					-- eg: { "efm", ... }
					ignore_lsp = { "pyright", "sumneko_lua", "null-ls", "gopls", "yamlls" },

					-- When set to false, you will get a message when project.nvim changes your
					-- directory.
					silent_chdir = false,
				})
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
		use({ "ygm2/rooter.nvim" })
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
