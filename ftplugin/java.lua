-- Install Java, this file is assuming that Sdkman is used as follows:
-- curl -s "https://get.sdkman.io" | bash
-- sdk install java 17.0.4-oracle
-- sdk install java 11.0.11-open
-- sdk install java 8.0.302-open
-- sdk install maven 3.8.6

-- Determine OS
local home = os.getenv("HOME")
local project_name = vim.fn.fnamemodify(vim.fn.finddir(".git/..", vim.fn.expand("%:p:h") .. ".;"), ":p:h:t")

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
    home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
    "-data",
    home .. "/workspace/" .. project_name,
  },
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
            path = home .. "/.sdkman/candidates/java/11.0.11-open/",
          },
          {
            name = "JavaSE-1.8",
            path = home .. "/.sdkman/candidates/java/8.0.302-open/",
          },
          {
            name = "JavaSE-17",
            path = home .. "/.sdkman/candidates/java/17.0.4-oracle/",
          },
        },
      },
    },
  },
}

config["on_attach"] = function(_, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)
  require("jdtls.dap").setup_dap_main_class_configs()
  jdtls.setup_dap({ hotcodereplace = "auto" })
  local lopts = { buffer = bufnr, noremap = true, silent = true }
  local function get_opts(desc)
    local description = desc or ""
    return vim.tbl_deep_extend("force", lopts, { desc = description })
  end

  -- stylua: ignore start
  vim.keymap.set( "n", "<C-e>", vim.diagnostic.open_float, lopts)
  vim.keymap.set( "n", "gD", vim.lsp.buf.declaration, get_opts("Goto declaration"))
  vim.keymap.set( "n", "gd", vim.lsp.buf.definition, get_opts("Goto definition"))
  vim.keymap.set( "n", "gr", vim.lsp.buf.references, get_opts("Goto references"))
  vim.keymap.set( "n", "gi", vim.lsp.buf.implementation, get_opts())
  vim.keymap.set( "n", "K", vim.lsp.buf.hover, get_opts())
  vim.keymap.set( "n", "<C-k>", vim.lsp.buf.signature_help, get_opts())
  vim.keymap.set( "n", "<leader>cwa", vim.lsp.buf.add_workspace_folder, get_opts("Add workspace folder"))
  vim.keymap.set( "n", "<leader>cwr", vim.lsp.buf.remove_workspace_folder, get_opts("Remove workspace folder"))
  vim.keymap.set( "n", "<leader>cwl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, get_opts("List workspace folders"))
  vim.keymap.set( "n", "<leader>cr", vim.lsp.buf.rename, get_opts("Rename"))
  vim.keymap.set( { "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>", get_opts("Code actions"))
  vim.keymap.set( "n", "[d", vim.diagnostic.goto_prev, get_opts())
  vim.keymap.set( "n", "]d", vim.diagnostic.goto_next, get_opts())
  vim.keymap.set( "n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, get_opts("Format"))
  -- stylua: ignore end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.java" },
  callback = function()
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

require("jdtls").start_or_attach(config)

local bufnr = vim.api.nvim_get_current_buf()
-- stylua: ignore start
vim.keymap.set("n", "<leader>co", jdtls.organize_imports, { desc = "Organize Imports", buffer = bufnr })
vim.keymap.set("n", "<leader>cv", jdtls.extract_variable, { desc = "Extract Variable", buffer = bufnr })
vim.keymap.set("n", "<leader>cc", jdtls.extract_constant, { desc = "Extract Constant", buffer = bufnr })
vim.keymap.set("v", "<leader>cv", function() jdtls.extract_variable({visual = true}) end, { desc = "Extract Variable", buffer = bufnr })
vim.keymap.set("v", "<leader>cc", function() jdtls.extract_constant({visual = true}) end, { desc = "Extract Constant", buffer = bufnr })
vim.keymap.set("v", "<leader>cm", function() jdtls.method({visual = true}) end, { desc = "Extract Method", buffer = bufnr })
vim.keymap.set("n", "<leader>cu", function() jdtls.update_project_config() end, { desc = "Update Config", buffer = bufnr })
vim.keymap.set("n", "<leader>tr", function() jdtls.test_nearest_method() vim.cmd.DapToggleRepl() end, { desc = "Run Nearest", buffer = bufnr })
vim.keymap.set("n", "<leader>tt", function() jdtls.test_class() vim.cmd.DapToggleRepl() end, { desc = "Run File", buffer = bufnr })
-- stylua: ignore end
