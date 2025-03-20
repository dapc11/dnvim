return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    shade_terminals = false
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    function _G.set_terminal_keymaps()
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = 0 })
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = 0 })
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { buffer = 0 })
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { buffer = 0 })
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { buffer = 0 })
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { buffer = 0 })
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], { buffer = 0 })
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
  keys = {
    { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>t", "<cmd>ToggleTermSendVisualSelection<cr>", desc = "Toggle terminal", mode = "v" }
  }
}
