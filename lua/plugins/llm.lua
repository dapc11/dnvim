local PROMPT =
  "You are a professional programming tutor and programming expert designed to help and guide me in learning programming. Your main goal is to help me learn programming concepts, best practices while writing code"
return {
  "robitx/gp.nvim",
  config = function()
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
      whisper = { disable = true },
      image = { disable = true },
      chat_assistant_prefix = { "🗨:" },
      log_file = "",
      providers = {
        openai = {
          endpoint = require("secret").OPEN_AI_URL,
          secret = require("secret").OPEN_API_TOKEN,
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

        -- your own functions can go here, see README for more examples like
        -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

        -- -- example of making :%GpChatNew a dedicated command which
        -- -- opens new chat with the entire current buffer as a context
        BufferChatNew = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
        end,
        Git = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "CommitMessage")
        end,
        -- -- example of adding command which writes unit tests for the selected code
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by writing table driven unit tests for the code above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.enew, agent, template)
        end,

        -- -- example of adding command which explains the selected code
        Explain = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by explaining the code above."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.popup, agent, template)
        end,
        CommitMessage = function(gp, params)
          local template = "Please write a commit message based on the Git diff in this file {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```"
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.enew, agent, template)
        end,
      },
    }
    require("gp").setup(conf)

    local function keymapOptions(desc)
      return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
      }
    end

    -- Chat commands
    vim.keymap.set({ "n", "i" }, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
    vim.keymap.set({ "n", "i" }, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
    vim.keymap.set({ "n", "i" }, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

    vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
    vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
    vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

    vim.keymap.set({ "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
    vim.keymap.set({ "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
    vim.keymap.set({ "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

    vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
    vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
    vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))

    -- Prompt commands
    vim.keymap.set({ "n", "i" }, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
    vim.keymap.set({ "n", "i" }, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
    vim.keymap.set({ "n", "i" }, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

    vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
    vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
    vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
    vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

    vim.keymap.set({ "n", "i" }, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
    vim.keymap.set({ "n", "i" }, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
    vim.keymap.set({ "n", "i" }, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
    vim.keymap.set({ "n", "i" }, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
    vim.keymap.set({ "n", "i" }, "<C-g>gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

    vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
    vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
    vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
    vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
    vim.keymap.set("v", "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))

    vim.keymap.set({ "n", "i" }, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
    vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

    vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
    vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

    -- optional Whisper commands with prefix <C-g>w
    vim.keymap.set({ "n", "i" }, "<C-g>ww", "<cmd>GpWhisper<cr>", keymapOptions("Whisper"))
    vim.keymap.set("v", "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", keymapOptions("Visual Whisper"))

    vim.keymap.set({ "n", "i" }, "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", keymapOptions("Whisper Inline Rewrite"))
    vim.keymap.set({ "n", "i" }, "<C-g>wa", "<cmd>GpWhisperAppend<cr>", keymapOptions("Whisper Append (after)"))
    vim.keymap.set({ "n", "i" }, "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", keymapOptions("Whisper Prepend (before) "))

    vim.keymap.set("v", "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", keymapOptions("Visual Whisper Rewrite"))
    vim.keymap.set("v", "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", keymapOptions("Visual Whisper Append (after)"))
    vim.keymap.set("v", "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", keymapOptions("Visual Whisper Prepend (before)"))

    vim.keymap.set({ "n", "i" }, "<C-g>wp", "<cmd>GpWhisperPopup<cr>", keymapOptions("Whisper Popup"))
    vim.keymap.set({ "n", "i" }, "<C-g>we", "<cmd>GpWhisperEnew<cr>", keymapOptions("Whisper Enew"))
    vim.keymap.set({ "n", "i" }, "<C-g>wn", "<cmd>GpWhisperNew<cr>", keymapOptions("Whisper New"))
    vim.keymap.set({ "n", "i" }, "<C-g>wv", "<cmd>GpWhisperVnew<cr>", keymapOptions("Whisper Vnew"))
    vim.keymap.set({ "n", "i" }, "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", keymapOptions("Whisper Tabnew"))

    vim.keymap.set("v", "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", keymapOptions("Visual Whisper Popup"))
    vim.keymap.set("v", "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", keymapOptions("Visual Whisper Enew"))
    vim.keymap.set("v", "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", keymapOptions("Visual Whisper New"))
    vim.keymap.set("v", "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", keymapOptions("Visual Whisper Vnew"))
    vim.keymap.set("v", "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", keymapOptions("Visual Whisper Tabnew"))
  end,
}

-- W
-- rite a for loop
