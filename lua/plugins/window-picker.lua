-- Required for picking windows in Neotree
return {
  "s1n7ax/nvim-window-picker",
  name = "window-picker",
  event = "VeryLazy",
  version = "2.*",
  opts = {
    selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
    hint = "floating-big-letter",
  },
}
