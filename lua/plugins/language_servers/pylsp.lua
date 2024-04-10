return {
  settings = {
    pylsp = {
      configurationSources = { "black", "flake8", "pylint", "pycodestyle", "pylsp_mypy", "pyls_isort" },
      plugins = {
        black = { enabled = true },
        flake8 = {
          enabled = true,
          maxLineLength = 200,
          extendIgnore = {
            "W503",
            "E501",
            "C812",
          },
        },
        pylint = {
          enabled = true,
          executable = "pylint",
          args = {
            "--max-line-length=200",
            "--disable=C0115,C0301,C0114,W0611,E0401,E0501,E0611",
          },
        },
        pycodestyle = { enabled = true },
        pylsp_mypy = { enabled = true },
        pyls_isort = { enabled = true },
      },
    },
  },
}
