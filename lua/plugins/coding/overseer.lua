vim.api.nvim_create_user_command("OverseerWatchRun", function()
  local overseer = require("overseer")
  overseer.run_template({ name = "run" }, function(task)
    if task then
      task:add_component({ "restart_on_save", paths = { vim.fn.expand("%:p") } })
      local main_win = vim.api.nvim_get_current_win()
      overseer.run_action(task, "open vsplit")
      vim.api.nvim_set_current_win(main_win)
    else
      vim.notify("WatchRun not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
    end
  end)
end, {})

return {
  {
    "stevearc/overseer.nvim",
    keys = {
      { "<leader>ow", ":OverseerWatchRun<cr>", desc = "Overseer Watch" },
      { "<leader>oa", ":OverseerTaskAction<cr>", desc = "Overseer Task Action" },
      { "<leader>oc", ":OverseerClose<cr>", desc = "Overseer Close" },
      { "<leader>od", ":OverseerDeleteBundle<cr>", desc = "Overseer Delete Bundle" },
      { "<leader>ol", ":OverseerLoadBundle<cr>", desc = "Overseer Load Bundle" },
      { "<leader>os", ":OverseerSaveBundle<cr>", desc = "Overseer Save Bundle" },
      { "<leader>oo", ":OverseerOpen<cr>", desc = "Overseer Open" },
      { "<leader>oq", ":OverseerQuickAction<cr>", desc = "Quick Action" },
      { "<leader>or", ":OverseerRun<cr>", desc = "Overseer Run" },
      { "<leader>ot", ":OverseerToggle<cr>", desc = "Overseer Toggle" },
    },
    opts = {
      component_aliases = {
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_notify",
          "on_complete_dispose",
        },
      },
      templates = { "builtin", "user.run", "user.run_local", "user.bob" },
    },
  },
}
