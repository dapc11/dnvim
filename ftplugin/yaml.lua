local function split(str, delimiter)
  local parts = {}
  for part in string.gmatch(str, "[^" .. delimiter .. "]+") do
    table.insert(parts, part)
  end
  return parts
end

local function fzf_yaml()
  require("fzf-lua").fzf_exec('yq e \'.. | select(. == "*") | {(path | join(".")): .}\' ' .. vim.fn.expand("%"), {
    actions = {
      ["default"] = function(selected, _)
        local parts = split(selected[1], ".")
        -- Jump to parent of leaf node to make next search accurate
        vim.fn.search(parts[#parts - 1])
        -- Find leaf node name from selected entry
        vim.fn.search(parts[#parts])
      end,
      ["ctrl-k"] = function(selected, _)
        vim.fn.setreg("+", split(selected[1], ":")[1])
      end,
      ["ctrl-v"] = function(selected, _)
        local value = ""
        for i, x in pairs(split(selected[1], ": ")) do
          if i ~= 1 then
            value = value .. x
          end
        end
        vim.fn.setreg("+", value)
      end,
    },
  })
end
vim.keymap.set("n", "<leader>fk", fzf_yaml, { desc = "Find YAML key", buffer = true })
vim.keymap.set("n", "gj", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })

