local function split(str, delimiter)
  return vim.split(str, delimiter, { plain = true, trimempty = true })
end

local function fzf_yaml()
  require("fzf-lua").fzf_exec('yq e \'.. | select(. == "*") | {(path | join(".")): .}\' ' .. vim.fn.expand("%"), {
    actions = {
      ["default"] = function(selected, _)
        local parts = split(selected[1], ".")
        -- Jump to parent of leaf node to make next search accurate. A
        -- top-level key has no parent, so there is nothing to jump to first.
        if #parts > 1 then
          vim.fn.search(parts[#parts - 1])
        end
        -- Find leaf node name from selected entry
        vim.fn.search(parts[#parts])
      end,
      ["ctrl-k"] = function(selected, _)
        vim.fn.setreg("+", split(selected[1], ":")[1])
      end,
      ["ctrl-v"] = function(selected, _)
        local parts = split(selected[1], ": ")
        table.remove(parts, 1)
        vim.fn.setreg("+", table.concat(parts, ": "))
      end,
    },
  })
end
vim.keymap.set("n", "<leader>fk", fzf_yaml, { desc = "Find YAML key", buffer = true })
vim.keymap.set("n", "gj", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })
