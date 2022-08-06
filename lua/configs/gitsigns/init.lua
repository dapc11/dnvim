local M = {}

function M.config()
  require("gitsigns").setup({
    on_attach = function(bufnr)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "hs", '<cmd>lua require"gitsigns".stage_hunk()<CR>', {})
      vim.api.nvim_buf_set_keymap(bufnr, "n", "hb", '<cmd>lua require"gitsigns".toggle_current_line_blame()<CR>', {})
      vim.api.nvim_buf_set_keymap(bufnr, "n", "hp", '<cmd>lua require"gitsigns".preview_hunk()<CR>', {})
    end,
    signs = {
      add = { hl = "GitSignsAdd", text = "┃", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      change = { hl = "GitSignsChange", text = "┃", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
      delete = { hl = "GitSignsDelete", text = "▁", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      topdelete = { hl = "GitSignsDelete", text = "▔", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    },
  })
end

return M
