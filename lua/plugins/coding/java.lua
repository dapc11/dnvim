return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "java" })
      end
    end,
  },
  { "mfussenegger/nvim-jdtls", event = "VeryLazy" },
  {
    "neovim/nvim-lspconfig",
    servers = {
      jdtls = {
        single_file_support = false,
      },
    },
  },
}
