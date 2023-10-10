return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("e", " " .. " New File",          ":ene <BAR> startinsert<CR>"),
      dashboard.button("f", " " .. " Find File",         ":FzfLua files<CR>"),
      dashboard.button("F", " " .. " Find All Files",    ":FzfLua files cwd=~<CR>"),
      dashboard.button("p", " " .. " Projects",          ":Telescope projects<CR>"),
      dashboard.button("r", " " .. " Recent Files",      ":FzfLua oldfiles<CR>"),
      dashboard.button("c", " " .. " Config",            ":e $MYVIMRC<CR>"),
      dashboard.button("l", " " .. " Plugin Management", ":Lazy<CR>"),
      dashboard.button("s", " " .. " Restore Session",   ":lua require('persistence').load({last = true })<CR>"),
      dashboard.button("b", " " .. " Notes",             ":ZkNotes<CR>"),
      dashboard.button("n", " " .. " New Note",          ":ZkNew<CR>"),
      dashboard.button("q", " " .. " Quit",              ":qa<CR>"),
    }

    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end

    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 8
    dashboard.section.header.val = { "" }

    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)
  end,
}
