return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    ---@class PluginLspOpts
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      },
      inlay_hints = {
        enabled = false,
      },
      capabilities = {},
      autoformat = true,
      format_notify = false,
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "jit", "vim", "lvim", "reload" },
              },
            },
          },
        },
      },
      setup = {},
    },
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- mappings
      vim.keymap.set('n', '<C-e>', vim.diagnostic.open_float)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local lopts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_deep_extend(
            "force", lopts, { desc = "Goto declaration" }))
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_deep_extend(
            "force", lopts, { desc = "Goto definition" }))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_deep_extend(
            "force", lopts, { desc = "Goto references" }))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_deep_extend(
            "force", lopts, { desc = "" }))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, lopts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, lopts)
          vim.keymap.set('n', '<leader>cwa', vim.lsp.buf.add_workspace_folder, vim.tbl_deep_extend(
            "force", lopts, { desc = "Add workspace folder" }))
          vim.keymap.set('n', '<leader>cwr', vim.lsp.buf.remove_workspace_folder, vim.tbl_deep_extend(
            "force", lopts, { desc = "Remove workspace folder" }))
          vim.keymap.set('n', '<leader>cwl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, vim.tbl_deep_extend(
            "force", lopts, { desc = "List workspace folders" }))
          vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, vim.tbl_deep_extend(
            "force", lopts, { desc = "Rename" }))
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_deep_extend(
            "force", lopts, { desc = "Code actions" }))
          vim.keymap.set('n', '<leader>cf', function()
            vim.lsp.buf.format { async = true }
          end, vim.tbl_deep_extend(
            "force", lopts, { desc = "Format" }))
        end,
      })

      local register_capability = vim.lsp.handlers["client/registerCapability"]

      vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        return register_capability(err, res, ctx)
      end

      -- diagnostics
      for name, icon in pairs(require("config.icons").icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end
    end,
  },
  -- cmdline tools and lsp servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
}
