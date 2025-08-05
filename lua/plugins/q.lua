return {
  "q.nvim",
  dir = "/home/epedape/repos_personal/q.nvim",
  dev = true,
  event = { "VeryLazy" },
  opts = {
    enabled = true,
    streaming = true,
    debug_cli = false,
    chat_window = {
      width = 80,
      height = 20,
      position = "right",
    },
  },
  keys = {
    { "<leader>qc", "<Plug>(QOpenChat)", desc = "Open Amazon Q chat" },
    { "<leader>qi", "<Plug>(QInlineChat)", mode = { "n", "v" }, desc = "Start Amazon Q inline chat" },
    { "<leader>ql", "<cmd>Q login<CR>", desc = "Login to Amazon Q" },
    { "<leader>qL", "<cmd>Q login-default<CR>", desc = "Quick login to Amazon Q" },
    { "<leader>qo", "<cmd>Q logout<CR>", desc = "Logout from Amazon Q" },
    { "<leader>qs", "<cmd>Q status<CR>", desc = "Check Amazon Q status" },
    { "<leader>qr", "<cmd>Q reopen<CR>", desc = "Reopen Amazon Q chat" },
    { "<leader>qC", "<cmd>Q clear<CR>", desc = "Clear Amazon Q chat history" },
  },
}
