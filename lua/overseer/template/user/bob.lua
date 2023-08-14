return {
  name = "Push to Sandbox",
  builder = function(_)
    return {
      cmd = "bob/bob",
      args = { "clean", "init", "build", "pre-integration-test" },
      name = "Push to sandbox",
      components = {
        "on_exit_set_status",
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
      },
    }
  end,
}
