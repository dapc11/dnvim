local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "gr", function()
  vim.cmd('noau normal! "vyi"')
  require("telescope.builtin").live_grep({
    default_text = 'include "' .. vim.fn.getreg("v") .. '"',
  })
end, { desc = "Find References", buffer = bufnr })

vim.keymap.set("n", "gd", function()
  vim.cmd('noau normal! "vyi"')
  require("telescope.builtin").live_grep({
    default_text = 'define "' .. vim.fn.getreg("v") .. '"',
    on_complete = {
      function(picker)
        -- remove this on_complete callback
        picker:clear_completion_callbacks()
        -- if we have exactly one match, select it
        if picker.manager.linked_states.size == 1 then
          require("telescope.actions").select_default(picker.prompt_bufnr)
        end
      end,
    },
  })
end, { desc = "Goto Definition", buffer = bufnr })
