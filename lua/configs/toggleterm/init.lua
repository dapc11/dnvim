local M = {}

function M.config()
  require("toggleterm").setup({
    open_mapping = [[<c-t>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = 1,
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = "horizontal", -- horizontal, vertcal, float
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
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

  local Terminal = require("toggleterm.terminal").Terminal
  -- local lazygit = Terminal:new({
  --   cmd = "lazygit",
  --   dir = "git_dir",
  --   direction = "float",
  --   -- function to run on opening the terminal
  --   on_open = function(term)
  --     vim.cmd("startinsert!")
  --     vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  --   end,
  --   -- function to run on closing the terminal
  --   on_close = function(term)
  --     vim.cmd("startinsert!")
  --   end,
  -- })
  --
  -- function _lazygit_toggle()
  --   lazygit:toggle()
  -- end
  --
  -- vim.api.nvim_set_keymap("n", "<C-g>", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })

  local float_term = Terminal:new({
    direction = "float",
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        "<m-1>",
        "<cmd>1ToggleTerm direction=float<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "t",
        "<m-1>",
        "<cmd>1ToggleTerm direction=float<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "i",
        "<m-1>",
        "<cmd>1ToggleTerm direction=float<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(term.bufnr, "", "<m-2>", "<nop>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(term.bufnr, "", "<m-3>", "<nop>", { noremap = true, silent = true })
    end,
    count = 1,
  })

  function _FLOAT_TERM()
    float_term:toggle()
  end

  vim.api.nvim_set_keymap("n", "<m-1>", "<cmd>lua _FLOAT_TERM()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("i", "<m-1>", "<cmd>lua _FLOAT_TERM()<CR>", { noremap = true, silent = true })

  local vertical_term = Terminal:new({
    direction = "vertical",
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        "<m-2>",
        "<cmd>2ToggleTerm size=60 direction=vertical<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "t",
        "<m-2>",
        "<cmd>2ToggleTerm size=60 direction=vertical<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "i",
        "<m-2>",
        "<cmd>2ToggleTerm size=60 direction=vertical<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(term.bufnr, "", "<m-3>", "<nop>", { noremap = true, silent = true })
    end,
    count = 2,
  })

  function _VERTICAL_TERM()
    vertical_term:toggle(60)
  end

  vim.api.nvim_set_keymap("n", "<m-2>", "<cmd>lua _VERTICAL_TERM()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("i", "<m-2>", "<cmd>lua _VERTICAL_TERM()<CR>", { noremap = true, silent = true })

  local horizontal_term = Terminal:new({
    direction = "horizontal",
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        "<m-3>",
        "<cmd>3ToggleTerm size=10 direction=horizontal<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "t",
        "<m-3>",
        "<cmd>3ToggleTerm size=10 direction=horizontal<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "i",
        "<m-3>",
        "<cmd>3ToggleTerm size=10 direction=horizontal<cr>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_buf_set_keymap(term.bufnr, "", "<m-2>", "<nop>", { noremap = true, silent = true })
    end,
    count = 3,
  })

  function _HORIZONTAL_TERM()
    horizontal_term:toggle(10)
  end

  vim.api.nvim_set_keymap("n", "<m-3>", "<cmd>lua _HORIZONTAL_TERM()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("i", "<m-3>", "<cmd>lua _HORIZONTAL_TERM()<CR>", { noremap = true, silent = true })
  -- if you only want these mappings for toggle term use term://*toggleterm#* instead
  vim.cmd("autocmd TermOpen term://*toggleterm#* silent! lua set_terminal_keymaps()")
end

return M
