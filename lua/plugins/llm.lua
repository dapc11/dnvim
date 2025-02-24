local secretLoadedSuccessfully, secret = pcall(require, "secret")

if not secretLoadedSuccessfully then
  print("Error loading 'secret.lua': File not found. Please create it and try again.")
elseif type(secret) ~= "table" or not (secret.OPENAI_API_TOKEN and secret.OPENAI_URL) then
  print("Invalid 'secret.lua' file: Return a table with keys 'OPENAI_API_TOKEN' and 'OPENAI_URL' set.")
end

local PROMPT = "You are a professional programming tutor and programming expert designed to help and guide me in learning programming. Your main goal is to help me learn programming concepts, best practices while writing code. "

local REVIEW_PROMPT = "Please review the following code." ..
"Consider:" ..
"1. Code quality and adherence to best practices" ..
"2. Potential bugs or edge cases" ..
"3. Performance optimizations" ..
"4. Readability and maintainability" ..
"5. Any security concerns" ..
"Suggest improvements and explain your reasoning for each suggestion."

local UNIT_TEST_PROMPT = "Generate unit tests for the following function:" ..
"Include tests for:" ..
"1. Normal expected inputs" ..
"2. Edge cases" ..
"3. Invalid inputs" ..
"Use [preferred testing framework] syntax."

local GIT_COMMIT_MESSAGE_PROMPT = "Write short commit messages:" ..
"- The first line should be a short summary of the changes and shall be max 50 chars"..
"- Body lines shall be max 72 chars or else split the line on multiple lines." ..
"- Be short and concise." ..
"- Remember to mention the files that were changed, and what was changed" ..
"- Explain the 'why' behind changes" ..
"- Use bullet points for multiple changes" ..
"- If there are no changes, or the input is blank - then return a blank string" ..
"" ..
"Think carefully before you write your commit message." ..
"" ..
"What you write will be passed directly to git commit -m '[message]'"

return {
  "robitx/gp.nvim",
  enabled = secretLoadedSuccessfully,
  keys = {
    { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew", mode = "v" },
    { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit", mode = "v" },
    { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split", mode = "v" },
    { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)", mode = "v" },
    { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)", mode = "v" },
    { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New", mode = "v" },
    { "<C-g>g", group = "generate into new .", mode = "v" },
    { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew", mode = "v" },
    { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew", mode = "v" },
    { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup", mode = "v" },
    { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew", mode = "v" },
    { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew", mode = "v" },
    { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection", mode = "v" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", mode = "v" },
    { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste", mode = "v" },
    { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite", mode = "v" },
    { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", mode = "v" },
    { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat", mode = "v" },
    { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext", mode = "v" },
    -- Normal mode
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
    { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
    -- Insert Mode
    { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew", mode = "i" },
    { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit", mode = "i" },
    { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split", mode = "i" },
    { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)", mode = "i" },
    { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)", mode = "i" },
    { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat", mode = "i" },
    { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder", mode = "i" },
    { "<C-g>g", group = "generate into new", mode = "i" },
    { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew", mode = "i" },
    { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew", mode = "i" },
    { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup", mode = "i" },
    { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew", mode = "i" },
    { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew", mode = "i" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", mode = "i" },
    { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite", mode = "i" },
    { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", mode = "i" },
    { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat", mode = "i" },
    { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext", mode = "i" },
  },
  config = function()
    local model = {
      model = "llama3.1-8b",
      input = 0.9,
      max_tokens = 16000,
      num_ctx = 131072,
      stream = true,
    }

    local function get_agent(name, chat, command, prompt, temperature)
      temperature = temperature or 0
      return{
          provider = "openai",
          name = name,
          chat = chat,
          command = command,
          model = vim.tbl_deep_extend("force",model, { temperature = temperature }),
          system_prompt = prompt,
        }
    end
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
      default_chat_agent = "chat",
      agents = {
        get_agent("chat", true, false, PROMPT, 0.5),
        get_agent("coder", false, true, PROMPT),
        get_agent("ut", false, true, UNIT_TEST_PROMPT),
        get_agent("review", true, false, REVIEW_PROMPT),
        get_agent("git", true, true, GIT_COMMIT_MESSAGE_PROMPT),
      },
      hooks = {
        -- -- example of adding command which writes unit tests for the selected code
        GenerateCommitMessage = function(gp, params)
          local buffer = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local template = "I have the following git diff:\n\n"
            .. "```diff\n"
            .. buffer
            .. "\n```\n\n"
            .. "Please generate a Git commit message with a subject of max 50 chars and a body where lines are max 72 chars. If there are many changes, provide a clear dash-based list describing the changes. Make sure the description is kept on a high-level."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.prepend, agent, template)
        end,
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by writing table driven unit tests for the code above."
          local agent = gp.get_command_agent("ut")
          gp.Prompt(params, gp.Target.enew, agent, template)
        end,
        Explain = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by explaining the code above."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.popup, agent, template)
        end,
        Review = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please analyze for code smells and suggest improvements."
          local agent = gp.get_chat_agent("review")
          gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
        end,
      },
    }
    require("gp").setup(conf)
  end,
}
