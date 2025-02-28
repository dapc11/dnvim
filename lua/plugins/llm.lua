local secretLoadedSuccessfully, secret = pcall(require, "secret")

if not secretLoadedSuccessfully then
  print("Error loading 'secret.lua': File not found. Please create it and try again.")
elseif type(secret) ~= "table" or not (secret.OPENAI_API_TOKEN and secret.OPENAI_URL) then
  print("Invalid 'secret.lua' file: Return a table with keys 'OPENAI_API_TOKEN' and 'OPENAI_URL' set.")
end

local PROMPT =
  "You are a professional programming tutor and programming expert designed to help and guide me in learning programming."
  .. "Your main goal is to help me learn programming concepts, best practices while writing code."
  .. "Please consider:"
  .. "- Readability"
  .. "- Clean code"
  .. "- Error handling"
  .. "- Edge cases"
  .. "- Security"
  .. "- Performance optimization"
  .. "- Best practices for the language currently used."
  .. "Please do not unnecessarily remove any comments or code."
  .. "Generate the code with clear comments explaining the logic."

local REVIEW_PROMPT = "Please review the following code."
  .. "Consider:"
  .. "1. Code quality and adherence to best practices"
  .. "2. Potential bugs or edge cases"
  .. "3. Performance optimizations"
  .. "4. Readability and maintainability"
  .. "5. Any security concerns"
  .. "Suggest improvements and explain your reasoning for each suggestion."

local UNIT_TEST_PROMPT = "Generate unit tests for the following function:"
  .. "Include tests for:"
  .. "1. Normal expected inputs"
  .. "2. Edge cases"
  .. "3. Invalid inputs"
  .. "Use [preferred testing framework] syntax."

local GIT_COMMIT_MESSAGE_PROMPT = "Write short commit messages:"
  .. "- The first line should be a short summary of the changes and shall be max 50 chars"
  .. "- Body lines shall be max 72 chars or else split the line on multiple lines."
  .. "- Be short and concise."
  .. "- Remember to mention the files that were changed, and what was changed"
  .. "- Explain the 'why' behind changes"
  .. "- Use bullet points for multiple changes"
  .. "- If there are no changes, or the input is blank - then return a blank string"
  .. ""
  .. "Think carefully before you write your commit message."
  .. ""
  .. "What you write will be passed directly to git commit -m '[message]'"

local model = {
  model = "llama3.1-8b",
  input = 0.9,
  max_tokens = 16000,
  num_ctx = 131072,
  stream = true,
}

local function get_agent(name, chat, command, prompt, temperature)
  temperature = temperature or 0
  return {
    provider = "openai",
    name = name,
    chat = chat,
    command = command,
    model = vim.tbl_deep_extend("force", model, { temperature = temperature }),
    system_prompt = prompt,
  }
end
return {
  "robitx/gp.nvim",
  enabled = secretLoadedSuccessfully,
  event = lazyfile,
  lazy = false,
  keys = {
    { "<C-g>-", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split", mode = "v" },
    { "<C-g>-", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
    { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)", mode = "v" },
    { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
    { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)", mode = "v" },
    { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
    { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New", mode = "v" },
    { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
    { "<C-g>e", ":<C-u>'<,'>GpExplain§<cr>", desc = "Explain", mode = "v" },
    { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
    { "<C-g>g", desc = "generate into new .", mode = { "v", "n" } },
    { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew", mode = "v" },
    { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
    { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew", mode = "v" },
    { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
    { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup", mode = "v" },
    { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
    { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew", mode = "v" },
    { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
    { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection", mode = "v" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", mode = "v" },
    { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste", mode = "v" },
    { "<C-g>r", ":<C-u>'<,'>GpReview<cr>", desc = "Review", mode = "v" },
    { "<C-g>R", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite", mode = "v" },
    { "<C-g>R", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
    { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
    { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", mode = "v" },
    { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat", mode = "v" },
    { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
    { "<C-g>v", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit", mode = "v" },
    { "<C-g>v", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
    { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext", mode = "v" },
    { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
  },
  opts = {
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
      Git = function(gp, params)
        local buffer = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        local template = "I have the following git diff:\n\n"
          .. "```diff\n"
          .. buffer
          .. "\n```\n\n"
          ..
          "Please generate a Git commit message with a subject of max 50 chars and a body where lines are max 72 chars." ..
          "If there are many changes, provide a clear dash-based list describing the changes. Make sure the description is kept on a high-level."
        local agent = gp.get_chat_agent("git")
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
        gp.Prompt(params, gp.Target.vnew("markdown"), agent, template)
      end,
    },
  },
}
