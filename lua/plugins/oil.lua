local close = {
  desc = "Close oil and restore original buffer",
  callback = function()
    local oilbuf = vim.api.nvim_get_current_buf()
    local ok = pcall(vim.cmd.bprev)
    if not ok then
      Snacks.picker.files()
    end
    vim.api.nvim_buf_delete(oilbuf, { force = true })
  end,
}

return {
  "stevearc/oil.nvim",
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
    prompt_save_on_select_new_entry = true,
    skip_confirm_for_simple_edits = true,
    cleanup_delay_ms = 2000,
    keymaps = {
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-v>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = close,
      ["q"] = close,
      ["<C-f>"] = function()
        vim.fn.feedkeys("/")
      end,
      ["f"] = function()
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
      ["g\\"] = "actions.toggle_trash",
    },
  },
  keys = {
    { "<leader>e", vim.cmd.Oil, desc = "Explorer", remap = true },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
