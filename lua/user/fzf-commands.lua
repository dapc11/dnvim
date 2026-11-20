--- <M-x>: every command, the ones most often picked here first. Picks are
--- counted in their own file, so commands typed at : or run by keymaps do not
--- affect the order.
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

return function()
  local picks = load()
  local commands = vim.fn.getcompletion("", "command")
  table.sort(commands, function(a, b)
    local pa, pb = picks[a] or 0, picks[b] or 0
    if pa ~= pb then
      return pa > pb
    end
    return a < b
  end)

  require("fzf-lua").fzf_exec(commands, {
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
        return require("fzf-lua.actions").ex_run(selected, opts)
      end,
    },
    -- Equal match scores keep list order, so frequent commands also win ties
    -- while typing.
    fzf_opts = { ["--tiebreak"] = "index", ["--no-multi"] = true },
  })
end
