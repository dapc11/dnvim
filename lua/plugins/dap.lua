return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Continue" })
      vim.keymap.set("n", "<leader>dq", function()
        dap.step_over()
      end, { desc = "Step over" })
      vim.keymap.set("n", "<leader>dw", function()
        dap.step_into()
      end, { desc = "Step in" })
      vim.keymap.set("n", "<leader>de", function()
        dap.step_out()
      end, { desc = "Step out" })
      vim.keymap.set("n", "<Leader>db", function()
        dap.toggle_breakpoint()
      end, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint()
      end, { desc = "Set breakpoint" })
      vim.keymap.set("n", "<Leader>dP", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, { desc = "Log point" })
      vim.keymap.set("n", "<Leader>dr", function()
        dap.repl.open()
      end, { desc = "Repl open" })
      vim.keymap.set("n", "<Leader>dl", function()
        dap.run_last()
      end, { desc = "Run Last" })
      vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Hover" })
      vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
        require("dap.ui.widgets").preview()
      end, { desc = "Preview" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
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
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {},
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
    config = function(_, opts)
      local dap = require("dap-python")
      dap.setup("python3", opts)
      dap.test_runner = "pytest"
    end,
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      dap_configurations = {
        {
          type = "go",
          name = "Attach remote",
          mode = "remote",
          request = "attach",
        },
      },
      delve = {
        path = "dlv",
        initialize_timeout_sec = 20,
        port = "${port}",
        args = {},
        build_flags = {},
        detached = vim.fn.has("win32") == 0,
      },
      tests = {
        verbose = false,
      },
    },
  },
}
