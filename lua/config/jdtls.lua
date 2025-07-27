local home = os.getenv("HOME")
local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })
local cache_vars = {}

-- Here you can add files/folders that you use at
-- the root of your project. `nvim-jdtls` will use
-- these to find the path to your project source code.
local root_files = {
  ".git",
  "mvnw",
  "gradlew",
  "pom.xml",
  "build.gradle",
}

local features = {
  -- change this to `true` to enable codelens
  codelens = false,

  -- change this to `true` if you have `nvim-dap`,
  -- `java-test` and `java-debug-adapter` installed
  debugger = false,
}

local function get_jdtls_paths()
  if cache_vars.paths then
    return cache_vars.paths
  end

  local path = {}

  path.data_dir = vim.fn.stdpath("cache") .. "/nvim-jdtls"

  -- TODO: get jdtls install path
  local jdtls_install = ""

  path.java_agent = jdtls_install .. "/lombok.jar"
  path.launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  path.platform_config = jdtls_install .. "/config_linux"
  path.bundles = {}

  ---
  -- Include java-test bundle if present
  ---
  -- TODO: get jdtls install path
  local java_test_path = ""

  local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n")

  if java_test_bundle[1] ~= "" then
    vim.list_extend(path.bundles, java_test_bundle)
  end

  ---
  -- Include java-debug-adapter bundle if present
  ---
  local java_debug_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()

  local java_debug_bundle =
      vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")

  if java_debug_bundle[1] ~= "" then
    vim.list_extend(path.bundles, java_debug_bundle)
  end

  ---
  -- Useful if you're starting jdtls with a Java version that's
  -- different from the one the project uses.
  ---
  path.runtimes = {
    {
      name = "JavaSE-11",
      path = home .. "/.sdkman/candidates/java/11.0.11-open/",
    },
    {
      name = "JavaSE-1.8",
      path = home .. "/.sdkman/candidates/java/8.0.302-open/",
    },
    {
      name = "JavaSE-17",
      path = home .. "/.sdkman/candidates/java/17.0.12-tem/",
    },
  }

  cache_vars.paths = path

  return path
end

local function enable_codelens()
  pcall(vim.lsp.codelens.refresh)

  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = true,
    group = java_cmds,
    desc = "refresh codelens",
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end,
  })
end

local opts = { buffer = true }
local function enable_debugger()
  local jdtls = require("jdtls")
  jdtls.setup_dap({ hotcodereplace = "auto" })
  require("jdtls.dap").setup_dap_main_class_configs()

  vim.keymap.set("n", "<leader>df", jdtls.test_class, opts)
  vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, opts)
end

local function jdtls_on_attach()
  local jdtls = require("jdtls")
  if features.debugger then
    enable_debugger()
  end

  if features.codelens then
    enable_codelens()
  end

  vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
  vim.keymap.set("n", "crv", jdtls.extract_variable, opts)
  vim.keymap.set("x", "crv", function() jdtls.extract_variable(true) end, opts)
  vim.keymap.set("n", "crc", jdtls.extract_constant, opts)
  vim.keymap.set("x", "crc", function() jdtls.extract_constant(true) end, opts)
  vim.keymap.set("x", "crm", function() jdtls.extract_method(true) end, opts)
end

local function jdtls_setup(_event)
  local jdtls = require("jdtls")

  local path = get_jdtls_paths()
  local data_dir = path.data_dir .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

  if cache_vars.capabilities == nil then
    jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
  end

  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  local cmd = {
    os.getenv("HOME") .. "/.sdkman/candidates/java/21.0.6-zulu/bin/java",
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
    path.launcher_jar,
    "-configuration",
    path.platform_config,
    "-data",
    data_dir,
  }

  local lsp_settings = {
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
          url = "file://" .. os.getenv("HOME") .. "/software/java_style.xml",
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
    },
  }

  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = cache_vars.capabilities,
    root_dir = jdtls.setup.find_root(root_files),
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
      bundles = path.bundles,
    },
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = java_cmds,
  pattern = { "java" },
  desc = "Setup jdtls",
  callback = jdtls_setup,
})
