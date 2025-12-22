local close = {
  desc = "Close oil and restore original buffer",
  callback = function()
    local oilbuf = vim.api.nvim_get_current_buf()
    pcall(vim.cmd.bprev)
    vim.api.nvim_buf_delete(oilbuf, { force = true })
  end,
}

return {
  "stevearc/oil.nvim",
  config = function(_, opts)
    require("oil").setup(opts)
    local last_dir = nil
    local function update_cwd()
      local current_dir = require("oil").get_current_dir()
      if current_dir ~= last_dir then
        vim.cmd("cd " .. current_dir)
        last_dir = current_dir
      end
    end
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
      pattern = "oil://*",
      callback = update_cwd,
    })
  end,
  opts = {
    win_options = {
      wrap = false,
      signcolumn = "no",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },
    view_options = {
      sort = {
        { "type", "asc" },
        { "name", "asc" },
      },
    },
    prompt_save_on_select_new_entry = true,
    skip_confirm_for_simple_edits = true,
    cleanup_delay_ms = 2000,
    keymaps = {
      ["<C-s>"] = function()
        require("oil").set_sort({ { "type", "asc" }, { "mtime", "desc" } })
      end,
      ["<C-v>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      --      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = close,
      ["q"] = close,
      ["<C-f>"] = function()
        vim.fn.feedkeys("/")
      end,
      ["f"] = function()
        vim.fn.feedkeys("/")
      end,
      ["s"] = function()
        vim.fn.feedkeys("/")
      end,
      ["r"] = "actions.refresh",
      ["<BS>"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["H"] = "actions.toggle_hidden",
      ["<C-h>"] = "actions.toggle_hidden",
      ["gd"] = function()
        require("oil").set_columns({ "permissions", "size", "mtime" })
      end,
      ["g\\"] = "actions.toggle_trash",
      ["<C-g>"] = function()
        require("fzf-lua").live_grep({ cwd = require("oil").get_current_dir() })
      end,
    },
  },
  keys = {
    { "<leader>e", vim.cmd.Oil, desc = "Explorer", remap = true },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
