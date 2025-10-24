local OPENAI_API_KEY = os.getenv("OPENAI_API_KEY") or ""
local OPENAI_URL = os.getenv("OPENAI_URL") or ""

local PROMPT =
    "You are a professional senior programmer.\n"
    .. " Response should be short and concise, and no yapping.\n"
    .. " Your main goal is to solve any given programming issue according to below considerations.\n"
    .. " Please consider:\n"
    .. " - Readability\n"
    .. " - Clean code\n"
    .. " - Error handling\n"
    .. " - Edge cases\n"
    .. " - Security\n"
    .. " - Performance optimization\n"
    .. " - Best practices for the language currently used."

local LEARNING_PROMPT =
    "You are a professional programming tutor and programming expert designed to help and guide me in learning programming.\n"
    .. "Your main goal is to help me learn programming concepts, best practices while writing code.\n"
    .. "Please consider:\n"
    .. "- Readability\n"
    .. "- Clean code\n"
    .. "- Error handling\n"
    .. "- Edge cases\n"
    .. "- Security\n"
    .. "- Performance optimization\n"
    .. "- Best practices for the language currently used."

local UNIT_TEST_PROMPT = "Generate unit tests for the following function."
    .. "Include tests for:\n"
    .. "- Normal expected inputs\n"
    .. "- Edge cases\n"
    .. "- Invalid inputs\n"
    .. "Use Pytest for Python and Ginkgo for Golang, and JUnit 5 for Java syntax."

local PRECISION_REVIEW_PROMPT =
    "You are 'The Precision Engineer' code reviewer. ONLY comment on demonstrable problems that will cause actual issues.\n\n"
    .. "Comment ONLY when you can PROVE one of these 7 specific problems:\n"
    .. "1. Compilation Error: Code will not compile (syntax errors, missing imports)\n"
    .. "2. Runtime Bug: Specific scenario where code will crash or fail\n"
    .. "3. Security Vulnerability: Actual exploitable weakness (SQL injection, XSS, etc.)\n"
    .. "4. Formatting Error: Missing newlines at EOF, trailing spaces, wrong indentation\n"
    .. "5. Pattern Violation: Clear deviation from patterns established in THIS codebase\n"
    .. "6. Logic Contradiction: Code behavior contradicts its own documentation/comments/naming\n"
    .. "7. Commit Message Issues: Body duplicates subject, missing required fields\n\n"
    .. "DO NOT comment on:\n"
    .. "- Style preferences ('could be better', 'minor comments')\n"
    .. "- Theoretical improvements without proven problems\n"
    .. "- Performance suggestions without benchmarks\n"
    .. "- Architecture opinions\n\n"
    .. "Response format:\n"
    .. "- If ANY issues found: List them specifically, then conclude with 'Issues found'\n"
    .. "- If NO issues found: Simply '+1'\n"
    .. "- Be consistent: Don't list issues then say '+1'"

local GIT_COMMIT_MESSAGE_PROMPT =
    "You are a git commit message writer. Your job is to analyze code diffs and write commit messages.\n\n"
    .. "A git commit message has two parts:\n"
    .. "1. Subject line: A single line that summarizes the change\n"
    .. "2. Body: Optional detailed explanation\n\n"
    .. "Subject line:\n"
    .. "- Start with imperative verb (Add, Fix, Update, Remove, etc.)\n"
    .. "- Capitalize first word\n"
    .. "- No period at end\n"
    .. "- Complete this sentence: 'If applied, this commit will [your subject]'\n\n"
    .. "Body:\n"
    .. "- Separate from subject with blank line\n"
    .. "- Explain WHAT changed and WHY it was necessary\n"
    .. "- Focus on business impact and user benefit, not code details\n"
    .. "- Don't describe the diff - explain the reasoning\n"
    .. "- Skip body if change is simple\n\n"
    .. "Style:\n"
    .. "- Be direct and factual\n"
    .. "- Avoid verbose explanations\n"
    .. "- No marketing language\n\n"
    .. "Example: 'Simplify serialize.h exception handling' not 'Update GIT_COMMIT_MESSAGE_PROMPT variable'\n"
    .. "Output format: Start directly with the subject line. No explanations, no 'Here is...' text."

local DEFAULT_MAX_TOKENS = 16000 -- Maximum tokens for LLM response
local DEFAULT_CONTEXT_SIZE = 131072 -- Context window size

local model = {
  model = "llama3.1-8b",
  input = 0.9,
  max_tokens = DEFAULT_MAX_TOKENS,
  num_ctx = DEFAULT_CONTEXT_SIZE,
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
  enabled = OPENAI_API_KEY ~= "",
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
    openai_api_key = OPENAI_API_KEY,
    whisper = { disable = true },
    image = { disable = true },
    chat_user_prefix = "## QUESTION --------------- 💬",
    chat_assistant_prefix = "## RESPONSE --------------- 🗨",
    log_file = "",
    providers = {
      openai = {
        endpoint = OPENAI_URL,
      },
    },
    default_chat_agent = "chat",
    agents = {
      get_agent("chat", true, false, LEARNING_PROMPT, 0.5),
      get_agent("coder", false, true, PROMPT),
      get_agent("ut", false, true, UNIT_TEST_PROMPT),
      get_agent("review", true, false, PRECISION_REVIEW_PROMPT),
      get_agent("git", true, true, GIT_COMMIT_MESSAGE_PROMPT),
    },
    hooks = {
      Git = function(gp, params)
        local diff = vim.fn.system("git diff --cached --no-color")

        -- If no staged changes, use inline diff for reword
        if vim.v.shell_error ~= 0 or diff == "" then
          local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          if buffer_content ~= "" then
            local template = "Improve this commit message:\n\n" .. buffer_content
            local agent = gp.get_chat_agent("git")
            gp.Prompt(params, gp.Target.prepend, agent, template)
            return
          else
            vim.notify("No staged changes or commit message found", vim.log.levels.WARN)
            return
          end
        end

        local template = "Analyze this git diff and write a commit message:\n\n" .. diff

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
        -- Check if user provided input (commit hash)
        local user_input = params.args or ""
        local diff = ""

        if user_input ~= "" then
          -- Review specific commit
          diff = vim.fn.system("git show --no-color " .. user_input)
          if vim.v.shell_error ~= 0 then
            vim.notify("Error getting commit: " .. user_input, vim.log.levels.ERROR)
            return
          end
        else
          -- Review staged changes
          diff = vim.fn.system("git diff --cached --no-color")
          if vim.v.shell_error ~= 0 or diff == "" then
            vim.notify("No staged changes found", vim.log.levels.WARN)
            return
          end
        end

        local template = "Review this code change:\n\n" .. diff .. "\n\n"
            .. "Apply precision engineering principles. Only flag demonstrable problems."
        local agent = gp.get_chat_agent("review")
        gp.Prompt(params, gp.Target.new("markdown"), agent, template)
      end,
    },
  },
}
