return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<C-a>",
      function()
        return require("dial.map").inc_normal()
      end,
      expr = true,
      desc = "Increment",
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_normal()
      end,
      expr = true,
      desc = "Decrement",
    },
  },
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.constant.alias.bool,
        augend.semver.alias.semver,
        augend.constant.new({ elements = { "let", "const" } }),
        augend.constant.new({ elements = { "True", "False" } }),
        augend.constant.new({
          word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
          elements = { "and", "or" },
          cyclic = true, -- "or" is incremented into "and".
        }),
        augend.constant.new({
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        }),
      },
    })
  end,
}
