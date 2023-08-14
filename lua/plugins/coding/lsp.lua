return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = true,
      severity_sort = true,
    },
    autoformat = true,
  },
}
