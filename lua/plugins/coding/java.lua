return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "java" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        jdtls = {
          diagnostics = {},
          root_dir = function(fname)
            local util = require("lspconfig.util")
            local root_files = {
              "pom.xml",
              "ruleset2.0.yaml",
            }
            return util.root_pattern(unpack(root_files))(fname)
              or util.root_pattern(".git")(fname)
              or util.path.dirname(fname)
          end,
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
                  url = "file://" .. os.getenv("HOME") .. ".config/nvim/ftplugin/java_style.xml",
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
                  enabled = "all",
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
        },
      },
    },
  },
}
