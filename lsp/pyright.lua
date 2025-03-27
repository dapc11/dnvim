return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", ".git" },
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        diagnosticSeverityOverrides = {
          reportImplicitRelativeImport = "none",
          reportMissingParameterType = "none",
          reportMissingTypeStubs = "none",
          reportOptionalSubscript = "none",
          reportUnannotatedClassAttribute = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownMemberType = "none",
          reportUnknownParameterType = "none",
          reportUnknownVariableType = "none"
        },
        inlayHints = {
          functionReturnTypes = false,
          callArgumentNames = false,
          variableTypes = false
        }
      },
    },
  },
}
