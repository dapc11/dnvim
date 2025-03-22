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

map("n", "Y", "y$")
map("v", "p", [["_dP]])

-- better indenting
map("n", "<tab>", "==", { remap = true })
map("n", "<c-i>", "<tab>", { remap = false })
map("v", "<tab>", "==")
map("i", "<tab>", "<c-t>", { remap = true })
map("i", "<s-tab>", "<c-d>", { remap = true })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<C-S-d>", "<c-u>", { remap = true })

map("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<S-Down>", "<cmd>m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<S-Up>", "<cmd>m '<-2<CR>gv=gv", { desc = "Move up" })

-- save file
map({ "i", "n" }, "<C-s>", "<cmd>w<CR><esc>", { desc = "Save file" })
map("n", "W", "<cmd>noautocmd w<CR>")

map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>v", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })

map("n", "<A-Down>", "}")
map("n", "<A-Up>", "{")

map("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Lazy" })
map("n", "<leader>ls", function()
  vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }))
  vim.diagnostic.enable(false, { bufnr = 0 })
  vim.opt_local.spell = false
end, { desc = "Stop all heavy lifting" })
map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "Lsp Info" })
map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Lsp Restart" })
map("n", "<leader>lL", "<cmd>LspLog<CR>", { desc = "Lsp Log" })

map("n", "<leader>j", "*``cgn", { desc = "Change under cursor" })
map("n", "<leader>.", [['<esc>' . repeat('.', v:count1)]], { desc = "Repeat cgn", expr = true })
map("c", "<C-v>", "<C-r>*")
map("i", "<C-v>", "<C-r>+")
map("n", "<C-c>", '"+y')
map("v", "<C-c>", '"+y')
map("v", "*", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>n]])
map("v", "#", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>N]])
map("n", ",", "@q")

map("n", "<M-x>", ":", { noremap = true, silent = false })
vim.cmd([[
  set wildcharm=<C-Z>
  cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
  cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
  cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
  cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"
  cnoremap <expr> <Tab>   getcmdtype() =~ '[\/?]' ? "<C-g>" : "<C-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[\/?]' ? "<C-t>" : "<S-Tab>"
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
end, { desc = "Goto CVE Definition" })

map("n", "<leader>zf", function()
  Snacks.picker.grep({ cwd = "~/notes/", path_shorten = true })
end, { desc = "Search in Notes" })
map("n", "<leader>zb", function()
  Snacks.picker.files({ cwd = "~/notes/", path_shorten = true })
end, { desc = "Browse Notes" })
map("n", "<leader>zn", function()
  require("util").create_note()
end, { desc = "New Note" })

map(
  "n",
  "<leader>xr",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor", silent = false }
)
map("v", "<leader>xr", function()
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")
  vim.api.nvim_input(":<C-u>" .. "%s/\\v(" .. text .. ")//gci<Left><Left><Left><Left>")
end, { noremap = true, silent = true, desc = "Interactive Replace" })

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
  vim.cmd(string.format("put =execute('%s')", x.args))
end, { nargs = "+", desc = "Dump output of a command at the cursor position" })

map("n", "gV", "`[v`]", { desc = "Select last paste" })

vim.keymap.set("n", "dd", function()
  if vim.fn.getline(".") == "" then return '"_dd' end
  return "dd"
end, { expr = true })
