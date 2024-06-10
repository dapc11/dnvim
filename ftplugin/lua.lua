vim.keymap.set("n", "<leader>cF", function()
  require("util").toggle_format("lua_format")
end, { desc = "Toggle Formatting", buffer = true })
