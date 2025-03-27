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
          reportUnknownParameterType = false,
          reportImplicitRelativeImport = false,
          reportMissingParameterType = false,
          reportMissingTypeStubs = false,
          reportOptionalSubscript = false,
          reportUnannotatedClassAttribute = false,
          reportUnknownArgumentType = false,
          reportUnknownLambdaType = false,
          reportUnknownMemberType = false,
          reportUnknownVariableType = false
        },
        inlayHints = {
          functionReturnTypes = true,
          callArgumentNames = true,
          variableTypes = true
        }
      },
    },
  },
}
