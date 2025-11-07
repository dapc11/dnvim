return {
  { "williamboman/mason.nvim", opts = {} },
  { "mfussenegger/nvim-jdtls", ft = "java" },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      require("nvim-goc").setup(opts)
    end,
  },
  {
    "fredrikaverpil/godoc.nvim",
    event = lazyfile,
    version = "2.x",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
