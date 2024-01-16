local function close_neo_tree()
  require("neo-tree.sources.manager").close_all()
  vim.notify("closed all")
end

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    options = vim.opt.sessionoptions:get(),
    pre_save = close_neo_tree,
  },
    -- stylua: ignore
    keys = {
      { "<leader>qr", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
}
