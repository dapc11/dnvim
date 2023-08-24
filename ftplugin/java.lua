-- Install Java, this file is assuming that Sdkman is used as follows:
-- curl -s "https://get.sdkman.io" | bash
-- sdk install java 17.0.4-oracle
-- sdk install java 11.0.11-open
-- sdk install java 8.0.302-open
-- sdk install maven 3.8.6

-- Determine OS
local home = os.getenv("HOME")
if vim.fn.has("mac") == 1 then
  WORKSPACE_PATH = home .. "/workspace/"
  CONFIG = "mac"
elseif vim.fn.has("unix") == 1 then
  WORKSPACE_PATH = home .. "/workspace/"
  CONFIG = "linux"
else
  print("Unsupported system")
end
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_dir = WORKSPACE_PATH .. project_name

local status, jdtls = pcall(require, "jdtls")
if not status then
  print("Failed to load jdtls.")
  return
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(
  bundles,
  vim.split(
    vim.fn.glob(mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
    "\n"
  )
)

local config = {
  cmd = {
    os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.4-oracle/bin/java", -- or '/path/to/java17_or_newer/bin/java'
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. CONFIG,
    "-data",
    workspace_dir,
  },
  root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "ruleset2.0.yaml" }, { upward = true })[1]),
  init_options = {
    bundles = bundles,
  },
  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      edit = {
        validateAllOpenBuffersOnChanges = false,
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      format = {
        comments = { enabled = false },
        enabled = true,
        insertSpaces = true,
        settings = {
          profile = "Code",
          url = "file://" .. home .. "/software/java_style.xml",
        },
        tabSize = 4,
      },
      saveActions = {
        organizeImports = true,
      },
      completion = {
        enabled = true,
        favoriteStaticMembers = {
          "java",
          "javax",
          "org",
          "",
          "com",
        },
        importOrder = {
          "java",
          "javax",
          "org",
          "",
          "junitparams",
          "",
          "com",
        },
      },
      cleanup = {
        "qualifyMembers",
        "qualifyStaticMembers",
        "addOverride",
        "addDeprecated",
        "stringConcatToTextBlock",
        "invertEquals",
        "addFinalModifier",
        "instanceofPatternMatch",
        "lambdaExpression",
        "switchExpression",
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = false,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      contentProvider = { preferred = "fernflower" },
      extendedClientCapabilities = extendedClientCapabilities,
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
      },
      useBlocks = true,
      signatureHelp = { enabled = true },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-11",
            path = os.getenv("HOME") .. "/.sdkman/candidates/java/11.0.11-open/",
          },
          {
            name = "JavaSE-1.8",
            path = os.getenv("HOME") .. "/.sdkman/candidates/java/8.0.302-open/",
          },
          {
            name = "JavaSE-17",
            path = os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.4-oracle/",
          },
        },
      },
    },
  },
}

config["on_attach"] = function(client, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)
  require("jdtls.dap").setup_dap_main_class_configs()
  jdtls.setup_dap({ hotcodereplace = "auto" })
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.java" },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

require("jdtls").start_or_attach(config)

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>co", jdtls.organize_imports, { desc = "Organize Imports", buffer = bufnr })
vim.keymap.set("n", "<leader>cv", jdtls.extract_variable, { desc = "Extract Variable", buffer = bufnr })
vim.keymap.set("n", "<leader>cc", jdtls.extract_constant, { desc = "Extract Constant", buffer = bufnr })
vim.keymap.set("v", "<leader>cv", function()
  jdtls.extract_variable(true)
end, { desc = "Extract Variable", buffer = bufnr })
vim.keymap.set("v", "<leader>cc", function()
  jdtls.extract_constant(true)
end, { desc = "Extract Constant", buffer = bufnr })
vim.keymap.set("v", "<leader>cm", function()
  jdtls.method(true)
end, { desc = "Extract Method", buffer = bufnr })
vim.keymap.set("n", "<leader>cu", function()
  jdtls.update_project_config()
end, { desc = "Update Config", buffer = bufnr })
vim.keymap.set("n", "<leader>tr", function()
  jdtls.test_nearest_method()
  vim.cmd.DapToggleRepl()
end, { desc = "Run Nearest", buffer = bufnr })
vim.keymap.set("n", "<leader>tt", function()
  jdtls.test_class()
  vim.cmd.DapToggleRepl()
end, { desc = "Run File", buffer = bufnr })
