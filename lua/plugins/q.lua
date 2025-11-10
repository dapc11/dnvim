return {
  {
    name = "amazonq",
    enabled = false,
    url = "https://github.com/awslabs/amazonq.nvim.git",
    opts = {
      ssoStartUrl = vim.env.Q_NVIM_IDENTITY_PROVIDER,
    },
  },
}
