return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        http = {
          eli_gateway = function()
            local token = os.getenv("ELI_JWT_TOKEN")
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "eli_gateway",
              formatted_name = "ELI Gateway",
              url = "https://gateway.eli.gaia.gic.ericsson.se/api/openai/v1/chat/completions",
              headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. token,
                ["Accept"] = "application/json",
              },
              raw = {
                "--insecure",
                "--http1.1",
              },
              handlers = {
                lifecycle = {
                  on_exit = function(self, data)
                    if data.status >= 400 then
                      vim.notify("ELI Error: " .. vim.inspect(data), vim.log.levels.ERROR)
                    end
                  end,
                },
                request = {
                  build_parameters = function(self, params, messages)
                    return vim.tbl_extend("force", params, {
                      messages = messages,
                      stream = true,
                    })
                  end,
                },
                response = {
                  parse_chat = function(self, data, tools)
                    local utils = require("codecompanion.utils.adapters")
                    local output = {}

                    if not data or data == "" then
                      return {
                        status = "success",
                        output = {},
                      }
                    end

                    data = utils.clean_streamed_data(data)
                    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })

                    if not ok or not json then
                      return {
                        status = "success", 
                        output = {},
                      }
                    end

                    -- Handle OpenAI format response
                    if json.choices and json.choices[1] and json.choices[1].delta then
                      local delta = json.choices[1].delta
                      if delta.content then
                        output.content = delta.content
                        output.role = delta.role or nil

                        return {
                          status = "success",
                          output = output,
                        }
                      end
                    end

                    return {
                      status = "success",
                      output = {},
                    }
                  end,
                  parse_inline = function(self, data, context)
                    if not data or data == "" then
                      return ""
                    end

                    local utils = require("codecompanion.utils.adapters")
                    data = utils.clean_streamed_data(data)
                    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true } })

                    if not ok or not json then
                      return ""
                    end

                    -- Handle OpenAI format response
                    if json.choices and json.choices[1] and json.choices[1].delta and json.choices[1].delta.content then
                      return json.choices[1].delta.content
                    end

                    return ""
                  end,
                },
              },
              schema = {
                model = {
                  order = 1,
                  mapping = "parameters",
                  type = "enum",
                  desc = "ID of the model to use from ELI Gateway",
                  default = "phi4-14b",
                  choices = {
                    "mistral-12b",
                    "qwen2.5-7b", 
                    "qwen3-8b",
                    "llama3.1-8b",
                    "phi4-14b",
                    "gpt-3.5 turbo",
                    "gpt-4",
                    "gpt-4 32k",
                    "gpt-4 turbo",
                    "gpt-4o",
                    "gpt-4o mini",
                    "o1",
                    "o1 mini",
                  },
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = "eli_gateway",
          opts = {
            system_prompt = "You are a professional senior programmer.\n"
              .. " Response should be short and concise, and no yapping.\n"
              .. " Your main goal is to solve any given programming issue according to below considerations.\n"
              .. " Please consider:\n"
              .. " - Readability\n"
              .. " - Clean code\n"
              .. " - Error handling\n"
              .. " - Edge cases\n"
              .. " - Security\n"
              .. " - Performance optimization\n"
              .. " - Best practices for the language currently used.",
          },
        },
        inline = {
          adapter = "eli_gateway",
        },
      },
      opts = {
        log_level = "ERROR",
      },
    })
  end,
}
