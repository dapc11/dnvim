local M = {}

local telescope = require("telescope.builtin")
local themes = require("telescope.themes")

function M.repo_grep()
  telescope.live_grep({
    cwd = "~/repos/",
    path_display = { "truncate", shorten = { len = 1, exclude = { 1, -1 } } },
    prompt_title = "Repos",
    layout_strategy = "vertical",
    layout_config = {
      height = 0.85,
      width = 0.75,
    },
  })
end
function M.repo_fd()
  telescope.find_files({
    cwd = "~/repos/",
    prompt_title = "Repos",
    layout_config = {
      height = 0.85,
    },
  })
end

function M.git_unstaged()
  telescope.git_files({ git_command = { "git", "ls-files", "--modified", "--exclude-standard" } })
end

function M.spell_check()
  telescope.spell_suggest(themes.get_cursor({
    prompt_title = "",
    layout_config = {
      height = 0.25,
      width = 0.25,
    },
  }))
end

return M
