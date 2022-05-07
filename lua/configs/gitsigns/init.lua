local M = {}

function M.config()
  require("gitsigns").setup({
    keymaps = {
      noremap = false,
    },
  })
end

return M
