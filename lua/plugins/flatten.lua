return {
  {
    "willothy/flatten.nvim",
    opts = {
      callbacks = {
        post_open = function(bufnr, winnr, ft, _)
          -- If it's a normal file, just switch to its window
          vim.api.nvim_set_current_win(winnr)

          -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
          if ft == "gitcommit" or ft == "gitrebase" or ft == "NeogitCommitMessage" then
            vim.api.nvim_create_autocmd("BufWritePost", {
              buffer = bufnr,
              once = true,
              callback = vim.schedule_wrap(function()
                vim.api.nvim_buf_delete(bufnr, {})
              end),
            })
          end
        end,
      },
    },
    config = true,
    lazy = false,
    priority = 1001,
  },
}
