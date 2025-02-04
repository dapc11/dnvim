local PROMPT =
  "You are a professional programming tutor and programming expert designed to help and guide me in learning programming. Your main goal is to help me learn programming concepts, best practices while writing code"
return {
  "robitx/gp.nvim",
  config = function()
    --- Merges multiple tables into one.
    --- @param ... table[] Tables to be merged.
    --- @return table Merged result of input tables.
    function MERGE_TABLE(...)
      return vim.tbl_deep_extend("force", ...)
    end
    local model = {
      model = "llama3.1-8b",
      max_tokens = 8192,
      num_ctx = 131072,
      stream = true,
    }
    local conf = {
      openai_api_key = require("secret").OPENAI_API_TOKEN,
      whisper = { disable = true },
      image = { disable = true },
      chat_user_prefix = "## QUESTION --------------- 💬",
      chat_assistant_prefix = "## RESPONSE --------------- 🗨",
      log_file = "",
      providers = {
        openai = {
          endpoint = require("secret").OPENAI_URL,
        },
      },
      default_chat_agent = "coder-chat",
      agents = {
        {
          provider = "openai",
          name = "chat",
          chat = true,
          command = false,
          model = MERGE_TABLE(model, { temperature = 0.7 }),
          system_prompt = PROMPT,
        },
        {
          provider = "openai",
          name = "coder",
          chat = false,
          command = true,
          model = MERGE_TABLE(model, { temperature = 0 }),
          system_prompt = PROMPT,
        },
      },
      hooks = {
        BufferChatNew = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
        end,
        -- -- example of adding command which writes unit tests for the selected code
        GenerateCommitMessage = function(gp, params)

          local buffer = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local template = "I have the following git diff:\n\n"
            .. "```diff\n" .. buffer .. "\n```\n\n"
            .. "Please generate a Git commit message with a subject of max 50 chars and a body where lines are max 72 chars. If there are many changes, provide a clear dash-based list describing the changes. Make sure the description is kept on a high-level."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.prepend, agent, template)
        end,
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by writing table driven unit tests for the code above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.enew, agent, template)
        end,
        Explain = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by explaining the code above."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.popup, agent, template)
        end,
        CodeReview = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please analyze for code smells and suggest improvements."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
        end,
      },
    }
    require("gp").setup(conf)
  end,
}
