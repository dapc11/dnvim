local map = require("util").map

map({ "n", "o", "x" }, ">", "[", { remap = true })
map({ "n", "o", "x" }, "<", "]", { remap = true })

map({ "i", "n" }, "<esc>", "<cmd>noh<CR><esc>", { desc = "Escape and clear hlsearch" })
map("n", "<C-z>", "<cmd>set wrap!<cr>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "*", "*Nzz")
map("n", "#", "#nzz")

map("n", "<leader>xd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

map({ "n", "v", "o" }, "ö", "{")
map({ "n", "v", "o" }, "ä", "}")

map("v", "p", [["_dP]])
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace", silent = false })
map("v", "<leader>s", [["hy:%s#<C-r>h##gc<left><left><left>]], { desc = "Replace", silent = false })
map("v", "<leader>S", [[:s###gc<left><left><left><left>]], { desc = "Replace", silent = false })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<S-Down>", '<cmd>m ">+1<CR>gv=gv', { desc = "Move down" })
map("v", "<S-Up>", '<cmd>m "<-2<CR>gv=gv', { desc = "Move up" })

map("n", "<C-s>", "/")
map("c", "<C-s>", "<C-g>")
map("n", "<A-s>", "?")
map("c", "<A-s>", "<C-t>")

map("n", "W", "<cmd>noautocmd w<CR>")

map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>v", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })

map("n", "<A-Down>", "}")
map("n", "<A-Up>", "{")
map("n", "<leader>ls", function()
  vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }))
  vim.diagnostic.enable(false, { bufnr = 0 })
  vim.opt_local.spell = false
end, { desc = "Stop all heavy lifting" })
map("n", "<leader>j", "*``cgn", { desc = "Change under cursor" })
map("n", "<leader>.", [["<esc>" . repeat(".", v:count1)]], { desc = "Repeat cgn", expr = true })
map("c", "<C-v>", "<C-r>*")
map("i", "<C-v>", "<C-r>+")
map("n", "<C-c>", '"+y')
map("v", "<C-c>", '"+y')
map("v", "*", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>n]])
map("v", "#", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>N]])
map("n", ",", "@q")
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


vim.cmd([[
  set wildcharm=<C-Z>
  cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
  cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
  cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
  cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"
  cnoremap <expr> <Tab>   getcmdtype() =~ "[\\/?]" ? "<C-g>" : "<C-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ "[\\/?]" ? "<C-t>" : "<S-Tab>"
  cnoremap <C-A>  <Home>
  cnoremap <C-B>  <Left>
  cnoremap <C-D>  <Del>
  cnoremap <C-E>  <End>
  cnoremap <Esc><C-B> <S-Left>
  cnoremap <Esc><C-F> <S-Right>
  inoremap <M-BS> <C-W>
  cnoremap <M-BS> <C-W>
]])

map("n", "]q", function()
  local qf = vim.fn.getqflist()
  if #qf > 0 then
    vim.cmd("cnext")
    vim.cmd("norm! zz")
  end
end, { desc = "Next Quickfix item" })
map("n", "[q", function()
  local qf = vim.fn.getqflist()
  if #qf > 0 then
    vim.cmd("cprev")
    vim.cmd("norm! zz")
  end
end, { desc = "Prev Quickfix item" })
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open Quickfix List" })

-- CVE finder
map("n", "gv", function()
  local cve = string.match(vim.fn.getline("."), "CVE%-%d+%-%d+")
  if cve then
    vim.fn.jobstart({ "xdg-open", "https://nvd.nist.gov/vuln/detail/" .. cve }, { detach = true })
  end
end)

-- Jira finder
map("n", "gj", function()
  require("util").jira_finder()
end, { desc = "Open Jira ticket" })

map("n", "<leader>xf", function()
  vim.api.nvim_input(":g//d<Left><Left>")
end, { noremap = true, silent = true, desc = "Filter lines by regex" })

map("n", "<leader>qo", function()
  local visible = {}
  for _, win in pairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if not visible[buf] then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end, { desc = "Close all other buffers" })

vim.api.nvim_create_user_command("Dump", function(x)
  local output = vim.fn.execute(x.args)
  vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
end, { nargs = "+", desc = "Dump output of a command at the cursor position" })

vim.api.nvim_create_user_command("Trim", function()
  -- Remove trailing whitespace
  vim.cmd([[%s/\s\+$//e]])
end, { desc = "Trim trailing whitespace and ensure single blank line at end" })

map("n", "gV", "`[v`]", { desc = "Select last paste" })

vim.keymap.set("n", "dd", function()
  if vim.fn.getline(".") == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })
map("n", "<leader>xS", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
end, { desc = "Stop Active LSP Clients" })

map("n", "<leader>zn", function()
  require("util").create_note()
end, { desc = "New Note" })

