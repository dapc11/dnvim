local M = {}

function M.config()
  local status_ok, lspconfig = pcall(require, "lspconfig")
  if not status_ok then
    return
  end

  local lsputils = require("utils")
  lsputils.lsp_handlers()

  local on_attach = function(client, bufnr)
    lsputils.lsp_keymaps(bufnr)
    lsputils.lsp_highlight_document(client)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
  end

  -- Use a loop to conveniently call "setup" on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = { "gopls" }
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = lsputils.capabilities,
      flags = lsputils.flags,
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          completeUnimported = true,
          staticcheck = true,
          buildFlags = { "-tags=integration,e2e" },
          hoverKind = "FullDocumentation",
          linkTarget = "pkg.go.dev",
          linksInHover = true,
          experimentalWorkspaceModule = true,
          experimentalPostfixCompletions = true,
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
            tidy = true,
          },
          usePlaceholders = true,

          completionDocumentation = true,
          deepCompletion = true,
        },
      },
    })
  end

  lspconfig.yamlls.setup({
    on_attach = on_attach,
    capabilities = lsputils.capabilities,
    flags = lsputils.flags,
    filetypes = { "yaml", "tpl", "gotmpl" },
    settings = {
      yaml = {},
    },
  })

  local sumneko_binary_path = vim.fn.expand("$HOME") .. "/software/lua-language-server/bin/lua-language-server"
  local sumneko_root_path = vim.fn.expand("$HOME") .. "/software/lua-language-server/"

  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  lspconfig.sumneko_lua.setup({
    cmd = { sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" },
    on_attach = on_attach,
    capabilities = lsputils.capabilities,
    flags = lsputils.flags,
    settings = {
      Lua = {
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim", "plugins" },
        },
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "Lua 5.3",
          -- Setup your lua path
          path = {
            "?.lua",
            "?/init.lua",
            vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
            vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
            "/usr/share/5.3/?.lua",
            "/usr/share/lua/5.3/?/init.lua",
          },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            vim.fn.expand("~/.luarocks/share/lua/5.3"),
            "/usr/share/lua/5.3",
          },
          ignoreDir = { ".git" },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })

  local util = require("lspconfig/util")
  lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = lsputils.capabilities,
    flags = lsputils.flags,
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "off",
          autoSearchPaths = true,
          useLibraryCodeForTypes = false,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
    root_dir = function(fname)
      return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
        or util.path.dirname(fname)
    end,
  })

  local win = require("lspconfig.ui.windows")
  local _default_opts = win.default_opts

  win.default_opts = function(options)
    local opts = _default_opts(options)
    opts.border = "single"
    return opts
  end
end

return M
