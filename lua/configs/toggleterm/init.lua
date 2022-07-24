local M = {}

function M.config()
  require("toggleterm").setup({
    open_mapping = [[<c-t>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = 1,
    start_in_insert = false,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = "single",
      winblend = 3,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
  })

  function _G.set_terminal_keymaps()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  end

  -- if you only want these mappings for toggle term use term://*toggleterm#* instead
  vim.cmd("autocmd TermOpen term://*toggleterm#* silent! lua set_terminal_keymaps()")
end

return M
