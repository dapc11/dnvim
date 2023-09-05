return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "gomod", "go", "gowork", "gosum" })
      end
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    opts = {
      disable_defaults = false,
      go = "go",
      gofmt = "gopls",
      lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
      lsp_document_formatting = true,
      max_line_len = 100,
      comment_placeholder = "",
      icons = { breakpoint = "", currentpos = "" },
      lsp_config = false,
      lsp_keymaps = true,
      sign_priority = 5,
      test_runner = "go", -- one of {`go`, `richgo`, `dlv`, `ginkgo`, `gotestsum`}
      luasnip = true,
      trouble = false,
    },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "gomodifytags", "impl", "gofumpt", "goimports-reviser", "delve" })
        end,
      },
      {
        "leoluz/nvim-dap-go",
        config = true,
      },
    },
  },
}
