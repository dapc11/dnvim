return {
  "echasnovski/mini.splitjoin",
  version = "*",
  opts = {
    mappings = {
      toggle = "gS",
      split = "",
      join = "",
    },
  },
  config = function(_, opts)
    require("mini.splitjoin").setup(opts)
  end,
}
