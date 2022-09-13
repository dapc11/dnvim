-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local jdtls_home = os.getenv("HOME") .. "/.local/jdtls"
local workspace_dir = jdtls_home .. "/workspace/" .. project_name

local capabilities = {
  workspace = {
    configuration = true,
  },
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
      },
    },
  },
}
local win = require("lspconfig.ui.windows")
local lsputils = require("configs.lsp.utils")
local _default_opts = win.default_opts

win.default_opts = function(options)
  local opts = _default_opts(options)
  opts.border = "single"
  return opts
end
lsputils.lsp_handlers()
local on_attach = function(client, bufnr)
  require("jdtls.setup").add_commands()
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  lsputils.lsp_keymaps(bufnr)
  lsputils.lsp_highlight_document(client)

  -- Mappings.
  local opts = { noremap = true, silent = true }
  -- Java specific
  buf_set_keymap("n", "<leader>di", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
  buf_set_keymap("n", "<leader>dt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
  buf_set_keymap("n", "<leader>dn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
  buf_set_keymap("v", "<leader>de", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
  buf_set_keymap("n", "<leader>de", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
  buf_set_keymap("v", "<leader>dm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

  buf_set_keymap("n", "<leader>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

local config = {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = {
    os.getenv("HOME") .. "/software/jdk-17.0.4.1/bin/java", -- or '/path/to/java17_or_newer/bin/java'
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
    jdtls_home .. "/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
    "-configuration",
    jdtls_home .. "/config_linux",
    "-data",
    workspace_dir,
  },
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "ruleset2.0.yaml" }),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      configuration = {
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- And search for `interface RuntimeOption`
        -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
        runtimes = {
          {
            name = "JavaSE-11",
            path = os.getenv("HOME") .. "/software/jdk-11.0.13/",
          },
          {
            name = "JavaSE-1.8",
            path = os.getenv("HOME") .. "/software/jdk1.8.0_311/",
          },
          {
            name = "JavaSE-17",
            path = os.getenv("HOME") .. "/software/jdk-17.0.4.1/",
          },
        },
      },
    },
  },
}
local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
config.init_options = {
  -- bundles = bundles;
  extendedClientCapabilities = extendedClientCapabilities,
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)
