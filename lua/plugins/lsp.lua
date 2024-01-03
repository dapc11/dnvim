return {
  {
    "stevearc/conform.nvim",
    events = lazyfile,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        go = { "goimports", "gofmt" },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    events = lazyfile,
    opts = {
      ensure_installed = {
        "stylua",
        "black",
        "goimports",
      },
    },
  },
  { "mfussenegger/nvim-jdtls", event = "VeryLazy" },
  {
    "VonHeikemen/lsp-zero.nvim",
    events = lazyfile,
    branch = "v3.x",
    dependencies = {
      { "williamboman/mason.nvim", events = lazyfile },
      { "williamboman/mason-lspconfig.nvim", events = lazyfile },
      { "neovim/nvim-lspconfig", events = lazyfile },
      {
        "L3MON4D3/LuaSnip",
        events = lazyfile,
      },
      { "saadparwaiz1/cmp_luasnip", events = lazyfile },
      { "hrsh7th/cmp-nvim-lsp", events = lazyfile },
      { "hrsh7th/cmp-nvim-lua", events = lazyfile },
      { "hrsh7th/cmp-buffer", events = lazyfile },
      { "hrsh7th/nvim-cmp", events = lazyfile },
    },
  },
  {
    "folke/neodev.nvim",
    config = false,
  },
}
