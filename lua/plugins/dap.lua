return {
  {
    "mfussenegger/nvim-dap",
    dependencies = { "mfussenegger/nvim-dap-python", "leoluz/nvim-dap-go", },
    config = function()
      vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "Continue" })
      vim.keymap.set('n', '<F6>', function() require('dap').step_over() end, { desc = "Step over" })
      vim.keymap.set('n', '<F7>', function() require('dap').step_into() end, { desc = "Step in" })
      vim.keymap.set('n', '<F8>', function() require('dap').step_out() end, { desc = "Step out" })
      vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end, { desc = "Toggle breakpoint" })
      vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end, { desc = "Set breakpoint" })
      vim.keymap.set('n', '<Leader>dP',
        function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
        { desc = "Log point" })
      vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end, { desc = "Repl open" })
      vim.keymap.set('n', '<Leader>dn', function() require('dap-python').test_method() end, { desc = "Run nearest" })
      vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end, { desc = "Run Last" })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
        require('dap.ui.widgets').hover()
      end, { desc = "Hover" })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
        require('dap.ui.widgets').preview()
      end, { desc = "Preview" })
      vim.keymap.set('n', '<Leader>df', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
      end, { desc = "Center float frames" })
      vim.keymap.set('n', '<Leader>ds', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
      end, { desc = "Center float widgets" })
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap"
    },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("python3")
      require("dap-python").test_runner = "pytest"
    end,
  },
}
