local M = {}

M.OPENAI_URL = os.getenv("OPENAI_URL") or "https://gateway.eli.gaia.gic.ericsson.se/api/openai/v1/chat/completions"
M.OPENAI_API_TOKEN = os.getenv("OPENAI_API_TOKEN") or ""
M.JIRA_URL = os.getenv("JIRA_URL") or "https://eteamproject-alpha.internal.ericsson.com/browse/"
M.JIRA_PATTERN = os.getenv("JIRA_PATTERN") or "ADPPRG%-%d%d%d%d%d%d?%d?"

return M
