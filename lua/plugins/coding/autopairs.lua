return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
  config = function(opts)
    local npairs = require("nvim-autopairs")
    local rule = require("nvim-autopairs.rule")

    npairs.setup(opts)
    npairs.add_rules({
      rule("\\" .. '"', ""),
      rule("\\" .. "[", ""),
    })
  end,
}
