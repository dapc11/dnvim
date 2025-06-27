return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<Leader>dB",
        function()
          require("dap").set_breakpoint()
        end,
        desc = "Set breakpoint",
      },
      {
        "<Leader>dP",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Log point",
      },
      {
        "<Leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<Leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Hover",
        mode = { "n", "v" },
      },
      {
        "<Leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<Leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        desc = "Preview",
        mode = { "n", "v" },
      },
      {
        "<Leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Repl open",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>de",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dq",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dw",
        function()
          require("dap").step_into()
        end,
        desc = "Step in",
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    event = lazyfile,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {},
    config = function(_, opts)
      require("dapui").setup(opts)
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
    event = lazyfile,
    dependencies = "mfussenegger/nvim-dap",
    opts = {},
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = "mfussenegger/nvim-dap",
    opts = {},
    config = function(_, opts)
      local dap = require("dap-python")
      dap.setup("python3", opts)
      dap.test_runner = "pytest"
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
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
