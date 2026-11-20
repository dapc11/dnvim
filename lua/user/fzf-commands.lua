--- <M-x>: every command plus the full lines from : history, like zsh's
--- Ctrl-R, so `Git push origin HEAD:refs/for/master` can be picked as is.
--- Order: most often picked here first (counted in their own file, so
--- commands typed at : or run by keymaps do not add to the count), then
--- history from newest to oldest, then the remaining command names.
-- ponytail: plain names, no per-kind colours or preview as in fzf.commands,
-- which offers no way to reorder its list. Rebuild those here if missed.
local storage = vim.fn.stdpath("data") .. "/fzf-command-picks.json"

local function load()
  if vim.fn.filereadable(storage) == 0 then
    return {}
  end
  local ok, picks = pcall(vim.json.decode, table.concat(vim.fn.readfile(storage), "\n"))
  return ok and type(picks) == "table" and picks or {}
end

--- History lines that name one commit, such as `Git commit --fixup=87e0ff82`
--- from fugitive's `cf`, `Git reset 3b80ac3^` or `Git push origin
--- 1fef27ee:refs/for/master`. Most are written by a keymap, not typed, and
--- the commit is a one-off, so picking the line again later is never wanted.
--- A commit is a whole word of 7 to 40 hex digits holding at least one digit,
--- which keeps out hex-looking words such as `defaced`.
-- ponytail: also drops lines with a 7+ digit number, like a date or an ID.
-- Narrow it to Git lines if that bites.
local function names_commit(line)
  for word in line:gmatch("%f[%w]%w+%f[%W]") do
    if #word >= 7 and #word <= 40 and word:match("^%x+$") and word:match("%d") then
      return true
    end
  end
  return false
end

--- Whether the command a history line starts with still exists, so lines for
--- removed plugins or typos are left out. Ranges and modifiers are
--- understood, so `%s/a/b/` and `silent !ls` count as `substitute` and `!`.
-- ponytail: a plugin that defines its commands only once loaded, such as
-- gitsigns on BufReadPost, has its lines hidden until then, as its command
-- names already are. Give it a `cmd =` spec if that bites.
local function command_exists(line)
  local ok, err = pcall(vim.api.nvim_parse_cmd, line, {})
  -- Only E492 means an unknown command. Other errors, such as E20 for a '<,'>
  -- range with no selection yet, are about the arguments.
  return ok or not tostring(err):find("E492", 1, true)
end

--- Newest-first rank of each : history line that has arguments. A lone word
--- such as `w` or `Lazy` is left out: it is an abbreviation or already in the
--- command list, and would only push the useful lines down. Lines differing
--- only in spacing, such as `Git fetch` and `Git  fetch`, look the same in the
--- list, so only the newest is kept.
-- ponytail: this also merges lines where the spacing matters, like
-- `%s/  / /g` and `%s/ / /g`. Key on the exact line if that ever bites.
local function history_ranks()
  local ranks, seen, rank = {}, {}, 0
  for i = vim.fn.histnr("cmd"), 1, -1 do
    -- Control characters are stray keys. fzf hides them, so they would only
    -- show up as duplicates.
    local line = vim.trim((vim.fn.histget("cmd", i):gsub("%c", "")))
    local key = line:gsub("%s+", " ")
    if
      line ~= ""
      and not line:match("^[%w!]+$")
      and not seen[key]
      and not names_commit(line)
      and command_exists(line)
    then
      seen[key] = true
      rank = rank + 1
      ranks[line] = rank
    end
  end
  return ranks
end

return function()
  local picks = load()
  local ranks = history_ranks()
  local entries = vim.fn.getcompletion("", "command")
  for line in pairs(ranks) do
    table.insert(entries, line)
  end
  table.sort(entries, function(a, b)
    local pa, pb = picks[a] or 0, picks[b] or 0
    if pa ~= pb then
      return pa > pb
    end
    local ra, rb = ranks[a] or math.huge, ranks[b] or math.huge
    if ra ~= rb then
      return ra < rb
    end
    return a < b
  end)

  require("fzf-lua").fzf_exec(entries, {
    prompt = "Commands> ",
    actions = {
      ["default"] = function(selected, opts)
        local name = selected[1]
        if name then
          -- ponytail: counted on pick, so a pick cancelled at the command line
          -- still counts. Hook CmdlineLeave if that skews the order.
          picks[name] = (picks[name] or 0) + 1
          vim.fn.writefile({ vim.json.encode(picks) }, storage)
        end
        -- Puts the line on the command line without running it, so a
        -- history line can still be edited before <CR>.
        return require("fzf-lua.actions").ex_run(selected, opts)
      end,
    },
    -- Equal match scores keep list order, so frequent and recent entries also
    -- win ties while typing.
    fzf_opts = { ["--tiebreak"] = "index", ["--no-multi"] = true },
  })
end
