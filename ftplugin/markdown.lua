vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Preview a Linked Note", buffer = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set("n", "<leader>zL", vim.cmd.ZkBacklinks, { desc = "Open Notes Linking to Buffer", buffer = true })
vim.keymap.set("n", "<leader>zf", vim.lsp.buf.definition, { desc = "Follow Link", buffer = true })
vim.keymap.set({ "v", "n" }, "<leader>zl", vim.cmd.ZkLinks, { desc = "Open Notes Linked by the Buffer", buffer = true })
vim.opt_local.wrap = true
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

vim.opt_local.comments = "b:*,b:-,b:+,n:>"
vim.opt_local.formatoptions:append("r")

vim.opt_local.colorcolumn = "100"

vim.api.nvim_create_user_command("VALint", function()
  local file = vim.fn.expand("%")
  local cmd = "~/repos_personal/va_report_linter/va_linter.py " .. vim.fn.shellescape(file)
  vim.fn.setqflist({}, "r", { lines = vim.fn.systemlist(cmd) })
  vim.cmd("copen")
end, {})
vim.keymap.set("n", "<leader>cl", "<cmd>VALint<cr>", { desc = "Lint", buffer = true })
vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Preview in Chrome", buffer = true })
vim.keymap.set("n", "gj", require("util").jira_finder, { desc = "Goto Jira Definition", buffer = true })
vim.keymap.set("n", "gf", require("user.markdown-links").follow, { desc = "Follow Link", buffer = true })

-- Refresh the preview when the file changes on disk (git, agents, other editors).
-- markdown-preview only refreshes on cursor events, so an external write never
-- reached the page. Watches the directory, not the file, so rename-on-save
-- writers that replace the inode keep being seen.
local buf = vim.api.nvim_get_current_buf()
local path = vim.api.nvim_buf_get_name(buf)
if not vim.b[buf].mkdp_watcher and path ~= "" then
  vim.b[buf].mkdp_watcher = true
  local name = vim.fs.basename(path)
  local watcher = assert(vim.uv.new_fs_event())
  watcher:start(vim.fs.dirname(path), {}, function(_, fname)
    if fname ~= name then return end
    vim.schedule(function()
      -- Only while :MarkdownPreview is on for this buffer.
      if not vim.api.nvim_buf_is_valid(buf) or vim.fn.exists("#MKDP_REFRESH_INIT" .. buf) == 0 then return end
      -- preview_refresh sends bufnr('%'), so run it with this buffer current.
      vim.api.nvim_buf_call(buf, function()
        vim.cmd.checktime(buf)
        vim.fn["mkdp#rpc#preview_refresh"]()
      end)
    end)
  end)
  vim.api.nvim_create_autocmd("BufWipeout", { buffer = buf, once = true, callback = function() watcher:close() end })
end
