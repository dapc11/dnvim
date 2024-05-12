local count_bufs_by_type = function(loaded_only)
  loaded_only = (loaded_only == nil and true or loaded_only)
  local count = { normal = 0, acwrite = 0, help = 0, nofile = 0, nowrite = 0, quickfix = 0, terminal = 0, prompt = 0 }
  local buftypes = vim.api.nvim_list_bufs()
  for _, bufname in pairs(buftypes) do
    if (not loaded_only) or vim.api.nvim_buf_is_loaded(bufname) then
      local buftype = vim.api.nvim_buf_get_option(bufname, "buftype")
      buftype = buftype ~= "" and buftype or "normal"
      count[buftype] = count[buftype] + 1
    end
  end
  return count
end

local function close_buffer()
  local bufTable = count_bufs_by_type()
  if bufTable.normal <= 1 then
    vim.cmd.close()
  else
    vim.cmd.bdelete()
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = require("util.common").ignored_filetypes,
  callback = function(event)
    local buf_ft = vim.bo.filetype
    if buf_ft ~= "oil" then
      vim.keymap.set("n", "q", close_buffer, { silent = true, buffer = true })
      vim.keymap.set("n", "<esc>", close_buffer, { silent = true, buffer = true })
      vim.keymap.set("n", "<c-c>", close_buffer, { silent = true, buffer = true })
    end
    vim.bo[event.buf].buflisted = false
    vim.opt.colorcolumn = "0"
    vim.keymap.set("n", "<c-j>", "j<CR>", { silent = true, buffer = true })
    vim.keymap.set("n", "<c-k>", "k<CR>", { silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "diff",
  callback = function(_)
    vim.diagnostic.disable()
    vim.keymap.set("n", "o", "<cmd>diffget //2<CR>", { expr = true, silent = true, buffer = true })
    vim.keymap.set("n", "t", "<cmd>diffget //3<CR>", { expr = true, silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufNewFile", "BufRead" }, {
  pattern = { "*.tpl", "*.yaml", "*.yml", "*.txt" },
  callback = function(event)
    local ft = ""
    if vim.fn.search("{{.*end.*}}", "nw") ~= 0 then
      print("Go tmpl found")
      ft = "gotmpl"
    elseif (vim.fn.search('{"version"', "nw") or vim.fn.search('{"message"', "nw")) ~= 0 then
      print("ADP Log file found")
      ft = "json"
    end
    if ft ~= "" then
      vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = event.buf }))
      vim.diagnostic.disable(event.buf)
      vim.opt_local.filetype = ft
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.keymap.set("n", "<c-c><c-c>", "<cmd>wq<CR>", { noremap = true, buffer = true })
    vim.keymap.set("i", "<c-c><c-c>", "<esc><cmd>wq<CR>", { noremap = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.b.miniindentscope_disable = true
    local dir = require("util.init").get_project_root(".git")
    if dir ~= nil then
      vim.cmd("cd " .. dir)
    end
  end,
})

-- always open quickfix window automatically.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
  pattern = { "[^l]*" },
  command = "cwindow",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
