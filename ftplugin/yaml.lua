local bufnr = vim.api.nvim_get_current_buf()
local split = require("util.common").split
local function fzf_yaml()
  require("fzf-lua").fzf_exec('yq e \'.. | select(. == "*") | {(path | join(".")): .}\' ' .. vim.fn.expand("%"), {
    actions = {
      ["default"] = function(selected, _)
        local parts = {}
        for part in string.gmatch(selected[1], "[^.]+") do
          table.insert(parts, part)
        end
        -- Jump to parent of leaf node to make next search accurate
        vim.fn.search(parts[#parts - 1])
        -- Find leaf node name from selected entry
        vim.fn.search(parts[#parts])
      end,
      ["ctrl-k"] = function(selected, _)
        for _, v in pairs(selected) do
          vim.fn.setreg("+", split(v, ":")[1])
          break
        end
      end,
      ["ctrl-v"] = function(selected, _)
        local value = ""
        for _, v in pairs(selected) do
          for i, x in pairs(split(v, ":")) do
            if i ~= 1 then
              value = value .. x
            end
          end
        end
        vim.fn.setreg("+", value)
      end,
    },
  })
end
vim.keymap.set("n", "<leader>fk", fzf_yaml, { desc = "YAML key", buffer = bufnr })
