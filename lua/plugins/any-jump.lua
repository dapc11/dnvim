return {
  "pechorin/any-jump.vim",
  keys = {
    { "<leader>,", ":AnyJump<cr>", desc = "Any Jump" },
  },
  config = function()
    vim.g.any_jump_window_width_ratio = 1
    vim.g.any_jump_window_height_ratio = 1
    vim.g.any_jump_window_top_offset = 4
  end,
}
