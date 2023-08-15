return {
  "monaqa/dial.nvim",
  keys = {
    {"<C-a>", mode = {"n", "v"}},
    {"<C-x>", mode = {"n", "v"}},
  },
  config = function()
    local augend = require("dial.augend")
    local config = require("dial.config")
    local map = require("dial.map")

    config.augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
      },
      typescript = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.constant.new({ elements = { "let", "const" } }),
      },
      visual = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
      },
      mygroup = {
        augend.constant.new({
          elements = { "and", "or" },
          word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
          cyclic = true, -- "or" is incremented into "and".
        }),
        augend.constant.new({
          elements = { "True", "False" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "public", "private" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        }),
        augend.date.alias["%m/%d/%Y"], -- date (03/12/2023, etc.)
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.semver.alias.semver,
      },
    })

    vim.keymap.set("n", "<C-a>", map.inc_normal("mygroup"), { noremap = true })
    vim.keymap.set("n", "<C-x>", map.dec_normal("mygroup"), { noremap = true })
    vim.keymap.set("v", "<C-a>", map.inc_normal("visual"), { noremap = true })
    vim.keymap.set("v", "<C-x>", map.dec_normal("visual"), { noremap = true })
  end
  }
