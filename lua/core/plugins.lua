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
			ft = { "text", "json", "yaml", "css", "html", "lua", "vim" },
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
					silent_chdir = true,
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
		use({
			"folke/which-key.nvim",
			config = function()
				require("which-key").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})
		use({
			"ThePrimeagen/refactoring.nvim",
			requires = {
				{ "nvim-lua/plenary.nvim" },
				{ "nvim-treesitter/nvim-treesitter" },
			},
			config = function()
				require("refactoring").setup({})
			end,
		})
		use({
			"ur4ltz/surround.nvim",
			config = function()
				require("surround").setup({ mappings_style = "sandwich" })
			end,
		})
		use({
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")
				dap.defaults.fallback.external_terminal = {
					command = "/usr/bin/alacritty",
					args = { "-e" },
				}
			end,
		})
		use({
			"rcarriga/nvim-dap-ui",
			requires = { "mfussenegger/nvim-dap" },
			config = function()
				local status_ok, dapui = pcall(require, "dapui")
				if not status_ok then
					return
				end

				dapui.setup()
				local dap = require("dap")
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
			"Pocco81/DAPInstall.nvim",
			after = "nvim-dap",
			requires = { "mfussenegger/nvim-dap" },
			config = function()
				require("dap-install").config("go", {})
			end,
		})
		use({
			"leoluz/nvim-dap-go",
			after = "DAPInstall.nvim",
			requires = { "mfussenegger/nvim-dap" },
			ft = "go",
			config = function()
				require("dap-go").setup()
				vim.api.nvim_set_keymap("n", "<leader>dt", require("dap-go").debug_test())
			end,
		})
		use({
			"mfussenegger/nvim-dap-python",
			after = "DAPInstall.nvim",
			requires = { "mfussenegger/nvim-dap" },
			ft = "py",
			config = function()
				-- Setup virtual env for debugpy is recommended
				-- mkdir .virtualenvs
				-- cd .virtualenvs
				-- python -m venv debugpy
				-- debugpy/bin/python -m pip install debugpy
				require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
				require("dap-python").test_runner = "pytest"
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
