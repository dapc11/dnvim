local show_dotfiles = true

local filter_show = function(_)
  return true
end

local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  require("mini.files").refresh({ content = { filter = new_filter } })
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    vim.keymap.set("n", "<c-h>", toggle_dotfiles, { buffer = buf_id })
  end,
})

return {
  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>fe",
        function(_)
          if not require("mini.files").close() then
            require("mini.files").open(vim.api.nvim_buf_get_name(0))
          end
        end,
        desc = "Explorer (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer", remap = true },
    },
    opts = {
      mappings = {
        go_in = "<Right>",
        go_in_plus = "<C-Right>",
        go_out = "<Left>",
        go_out_plus = "<C-Left>",
      },
    },
  },
}
