local M = {}

-- State to track open terminal
local q_terminal = {
  bufnr = nil,
  winid = nil,
  job_id = nil,
}

-- Expand % to current file path
local function expand_file_path(message)
  if message and message:find("%%") then
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file and current_file ~= "" then
      return message:gsub("%%", current_file)
    end
  end
  return message
end

-- Open Amazon Q chat terminal
function M.open_chat(message)
  -- If terminal is already open, focus it
  if q_terminal.winid and vim.api.nvim_win_is_valid(q_terminal.winid) then
    vim.api.nvim_set_current_win(q_terminal.winid)

    -- Send message if provided
    if message and q_terminal.job_id then
      local expanded = expand_file_path(message)
      vim.api.nvim_chan_send(q_terminal.job_id, expanded .. "\n")
    end
    return
  end

  -- Create new terminal window
  vim.cmd("vsplit")
  q_terminal.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, q_terminal.bufnr)
  q_terminal.winid = vim.api.nvim_get_current_win()

  -- Start Amazon Q CLI
  q_terminal.job_id = vim.fn.termopen("q chat", {
    on_exit = function()
      q_terminal = { bufnr = nil, winid = nil, job_id = nil }
    end,
  })

  -- Send initial message if provided
  if message and q_terminal.job_id then
    local expanded = expand_file_path(message)
    vim.api.nvim_chan_send(q_terminal.job_id, expanded .. "\n")
  end
end

-- Close Amazon Q terminal
function M.close_chat()
  if q_terminal.winid and vim.api.nvim_win_is_valid(q_terminal.winid) then
    vim.api.nvim_win_close(q_terminal.winid, true)
  end
  q_terminal = { bufnr = nil, winid = nil, job_id = nil }
end

-- Toggle Amazon Q terminal
function M.toggle_chat()
  if q_terminal.winid and vim.api.nvim_win_is_valid(q_terminal.winid) then
    M.close_chat()
  else
    M.open_chat()
  end
end

-- Create user commands
vim.api.nvim_create_user_command("Q", function(opts)
  local args = opts.fargs
  if #args == 0 or args[1] == "chat" then
    local message = #args > 1 and table.concat(vim.list_slice(args, 2), " ") or nil
    M.open_chat(message)
  elseif args[1] == "toggle" then
    M.toggle_chat()
  elseif args[1] == "close" then
    M.close_chat()
  else
    vim.notify("Usage: :Q [chat [message] | toggle | close]", vim.log.levels.INFO)
  end
end, {
  nargs = "*",
  desc = "Amazon Q CLI integration",
})

-- Create keymap
vim.keymap.set("n", "<leader>qc", M.toggle_chat, { desc = "Toggle Amazon Q chat" })

return M
