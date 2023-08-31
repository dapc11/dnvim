local bufnr = vim.api.nvim_get_current_buf()
function getVisualSelection()
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
  '"vyi"<cmd>lua require("telescope.builtin").live_grep({ default_text = getVisualSelection() })<cr>',
  { desc = "Find Usages", buffer = bufnr }
)
