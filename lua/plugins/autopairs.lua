return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function(opts)
    local lopts = opts or {}
    local npairs = require("nvim-autopairs")
    local rule = require("nvim-autopairs.rule")

    npairs.setup(lopts)
    npairs.add_rules({
      rule("\\" .. '"', ""),
      rule("\\" .. "[", ""),
    })
  end,
}
