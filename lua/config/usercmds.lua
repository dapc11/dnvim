vim.api.nvim_create_user_command("CopyPath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied to clipboard: " .. path)
end, { desc = "Copy full file path to clipboard" })

vim.api.nvim_create_user_command("CopyCmd", function(x)
  vim.fn.setreg("+", vim.fn.execute(x.args))
end, { nargs = 1 })

vim.api.nvim_create_user_command("CopyMsg", function()
  local lines = vim.split(vim.fn.execute("messages"), "\n")
  -- :messages output is fenced by blank lines, which would show up as stray
  -- empty lines when the register is put back into a buffer.
  while lines[1] == "" do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  if #lines == 0 then
    print("No messages to copy")
    return
  end
  vim.fn.setreg("+", lines, "l")
  print(("Copied %d message line(s) to clipboard"):format(#lines))
end, { desc = "Copy :messages output to clipboard" })

vim.api.nvim_create_user_command("Dump", function(x)
  local output = vim.fn.execute(x.args)
  vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
end, { nargs = "+", desc = "Dump output of a command at the cursor position" })

vim.api.nvim_create_user_command("Trim", function()
  -- Remove trailing whitespace
  vim.cmd([[%s/\s\+$//e]])
end, { desc = "Trim trailing whitespace and ensure single blank line at end" })

--- Meld-style side by side view. During a conflicted merge diffview shows its
--- merge tool, otherwise the working tree against HEAD.

--- Pick a merge-tool layout the conflict can actually render. diffview fails
--- with "Failed to create diff buffer: ':N:<path>'" when it is asked for a pane
--- whose git stage is absent, and not every conflict has all three:
---
---   content conflict   stages 1,2,3   BASE, OURS, THEIRS
---   add/add            stages 2,3     no common ancestor
---   delete/modify      stages 1,2     no THEIRS, the file is gone there
---
---@param paths string[] unmerged paths
---@return string layout
local function merge_layout(paths)
  local all_three, ours_and_theirs = true, true

  for _, path in ipairs(paths) do
    local stages = {}
    for _, line in ipairs(vim.fn.systemlist({ "git", "ls-files", "-u", "--", path })) do
      local stage = line:match("^%S+%s+%S+%s+(%d)\t")
      if stage then
        stages[stage] = true
      end
    end
    if not (stages["1"] and stages["2"] and stages["3"]) then
      all_three = false
    end
    if not (stages["2"] and stages["3"]) then
      ours_and_theirs = false
    end
  end

  if all_three then
    return "diff4_mixed"
  elseif ours_and_theirs then
    return "diff3_horizontal"
  end
  -- A missing OURS or THEIRS leaves nothing to put side by side.
  return "diff1_plain"
end

--- Last file shown per repository, so a closed :Meld opens where it left off.
--- Resolutions survive the close on their own: the merged buffer is the real
--- file, which diffview leaves loaded.
local meld_last = {}

---@return boolean whether `view` is a diffview DiffView, as :Meld opens
local function is_meld_view(view)
  return view ~= nil and view:instanceof(require("diffview.scene.views.diff.diff_view").DiffView)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "DiffviewDiffBufWinEnter",
  group = vim.api.nvim_create_augroup("user_meld_resume", { clear = true }),
  desc = "Remember the file :Meld shows",
  callback = function()
    local view = require("diffview.lib").get_current_view()
    if is_meld_view(view) and view.cur_entry then
      meld_last[view.adapter.ctx.toplevel] = view.cur_entry.path
    end
  end,
})

vim.api.nvim_create_user_command("Meld", function(opts)
  local toplevel = vim.fn.systemlist({ "git", "rev-parse", "--path-format=absolute", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Meld: not inside a git repository", vim.log.levels.WARN)
    return
  end

  -- Still open, perhaps in another tab: go back to it as it is.
  if opts.args == "" then
    for _, view in ipairs(require("diffview.lib").views) do
      if
        is_meld_view(view)
        and view.adapter.ctx.toplevel == toplevel
        and vim.api.nvim_tabpage_is_valid(view.tabpage)
      then
        vim.api.nvim_set_current_tabpage(view.tabpage)
        return
      end
    end
  end

  local unmerged = vim.fn.systemlist("git diff --name-only --diff-filter=U")
  if vim.v.shell_error ~= 0 then
    unmerged = {}
  end

  if #unmerged > 0 then
    -- Only the layout: setup() would reset the rest of the config to defaults.
    require("diffview.config").get_config().view.merge_tool.layout = merge_layout(unmerged)
  end

  local args = opts.args
  if meld_last[toplevel] then
    -- Does nothing once that file has dropped out of the view.
    args = args .. " --selected-file=" .. vim.fn.fnameescape(meld_last[toplevel])
  end
  vim.cmd("DiffviewOpen " .. args)

  if #unmerged > 0 then
    vim.notify(
      ("Meld: %d conflicted file(s). ]x/[x to move, <leader>ca/cb/cc to pick, q to close"):format(#unmerged),
      vim.log.levels.INFO
    )
  end
end, {
  nargs = "*",
  desc = "Meld-style merge/diff view (diffview.nvim)",
})

vim.api.nvim_create_user_command("MeldClose", function()
  vim.cmd("DiffviewClose")
end, { desc = "Close the Meld view" })

-- Command typo fixes (abbreviations handle both :W and :W!)
--
-- Guarded with <expr> so they only fire when the abbreviation is the entire
-- command line of a ":" command. Unguarded, cnoreabbrev rewrites the text
-- anywhere a bare "W" appears, which corrupts arguments such as ":e W.txt"
-- and ":CopyCmd W".
local abbrevs = { W = "w", Wq = "wq", Wqa = "wqa", WQ = "wq", Q = "q", Qa = "qa", Qw = "wq" }
for from, to in pairs(abbrevs) do
  for _, bang in ipairs({ "", "!" }) do
    local lhs, rhs = from .. bang, to .. bang
    vim.cmd(
      string.format(
        "cnoreabbrev <expr> %s (getcmdtype() ==# ':' && getcmdline() ==# %s) ? %s : %s",
        lhs,
        vim.fn.string(lhs),
        vim.fn.string(rhs),
        vim.fn.string(lhs)
      )
    )
  end
end
