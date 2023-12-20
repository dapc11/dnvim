return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      enable_diagnostics = false,
      enable_git_status = false,
      filesystem = {
        bind_to_cwd = false,
        use_libuv_file_watcher = false,
      },
    },
  },
  {
    "haya14busa/vim-asterisk",
    lazy = false,
    init = function()
      vim.cmd([[
        map *   <Plug>(asterisk-*)
        map #   <Plug>(asterisk-#)
        map g*  <Plug>(asterisk-g*)
        map g#  <Plug>(asterisk-g#)
        map z*  <Plug>(asterisk-z*)
        map gz* <Plug>(asterisk-gz*)
        map z#  <Plug>(asterisk-z#)
        map gz# <Plug>(asterisk-gz#)
      ]])
    end,
  },
  {
    "folke/flash.nvim",
    opts = {
      modes = { search = { enabled = false } },
    },
  },
}
