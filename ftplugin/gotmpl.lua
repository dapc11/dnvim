local bufnr = vim.api.nvim_get_current_buf()
function GetVisualSelection()
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return '"' .. text .. '"'
  else
    return ""
  end
end

vim.keymap.set(
  "n",
  "gf",
  '"vyi"<cmd>lua require("telescope.builtin").live_grep({ default_text = GetVisualSelection() })<cr>',
  { desc = "Find Usages", buffer = bufnr }
)
