local M = {}

function M.config()
  local status_ok, npairs = pcall(require, "nvim-autopairs")
  if not status_ok then
    return
  end

  npairs.setup({
    disable_in_visualblock = true,
    check_ts = true,
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    ts_config = {
      lua = { "string" },
      python = { "string" },
      go = { "string" },
    },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'", " " },
      pattern = string.gsub([[ [% %'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = -1, -- Offset from pattern match
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  })
  require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })
end

return M
