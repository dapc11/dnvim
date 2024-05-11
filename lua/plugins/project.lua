return {
  "ahmedkhalf/project.nvim",
  opts = {
    detection_mehods = { "pattern", "lsp" },
    patterns = { ".git", ".stylua.toml", ".gitignore", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
  },
  config = function(opts)
    require("project_nvim").setup(opts)
  end,
}
