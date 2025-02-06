local success, secret = pcall(require, "secret")

if not success then
  print('"secret.lua" is missing, please create it. Will not load gp.nvim.')
elseif type(secret) ~= "table" then
  success = false
  print('"secret.lua" is empty or invalid. Return a table with keys "OPENAI_API_TOKEN" and "OPENAI_URL" set. Will not load gp.nvim.')
end

local PROMPT =
  "You are a professional programming tutor and programming expert designed to help and guide me in learning programming. Your main goal is to help me learn programming concepts, best practices while writing code"
return {
  "robitx/gp.nvim",
  enabled = success,
  dependencies = {
    { "folke/which-key.nvim" },
  },
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
      openai_api_key = secret.OPENAI_API_TOKEN,
      whisper = { disable = true },
      image = { disable = true },
      chat_user_prefix = "## QUESTION --------------- 💬",
      chat_assistant_prefix = "## RESPONSE --------------- 🗨",
      log_file = "",
      providers = {
        openai = {
          endpoint = secret.OPENAI_URL,
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

    require("which-key").add({
      {
        mode = { "v" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
        { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
        { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split" },
        { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
        { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
        { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
        { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
        { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
        { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
        { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
        { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
        { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append" },
        { "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
        { "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
        { "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext" },
      },

      -- NORMAL mode mappings
      {
        mode = { "n" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
      },

      -- INSERT mode mappings
      {
        mode = { "i" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
      },
    })
  end,
}
