return {
  "gbprod/yanky.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
    "folke/snacks.nvim",
  },
  opts = {
    ring = { storage = "sqlite" },
    highlight = {
      timer = 100,
    },
  },
  keys = {
    {
      "<leader>p",
      function()
        local mode = vim.fn.mode()
        if mode:match("[vV]") then
          Snacks.picker.yanky({
            confirm = function(picker)
              picker:close()
              local selected = picker:selected({ fallback = true })
              if vim.tbl_count(selected) == 1 then
                require("yanky.picker").actions.put("p", true)(selected[1])
              end
            end,
          })
        else
          Snacks.picker.yanky()
        end
      end,
      mode = { "n", "x", "v" },
      desc = "Open Yank History / Replace Selection",
    },
    { "y", "<Plug>(YankyYank)", mode = { "n", "x", "v" }, desc = "Yank text" },
  },
}
