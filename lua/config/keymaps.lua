local map = require("util").map

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<CR><esc>", { desc = "Escape and clear hlsearch" })

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("n", "*", "*Nzz")
map("n", "#", "#nzz")
map("n", "g*", "g*zz")

map("n", "==", "gg=G")

map({ "n", "v" }, "ö", "{")
map({ "n", "v" }, "ä", "}")

map("n", "gw", "*N", { desc = "Search word under cursor" })

map("x", "<leader>p", '"_dP')
map({ "n", "v" }, "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace", silent = false })
map("v", "<leader>s", [["hy:%s#<C-r>h##gc<left><left><left>]], { desc = "Replace", silent = false })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- save file
map({ "i", "n" }, "<C-s>", "<cmd>w<CR><esc>", { desc = "Save file" })
map("n", "W", "<cmd>noautocmd w<CR>")

map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>v", "<C-W>v", { desc = "Split window right", remap = true })

-- Move to window using the <ctrl> arrow keys
map("n", "<C-Left>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Go to right window", remap = true })
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Move Lines
map("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move up" })
map("n", "Q", ":tabclose<CR>", { desc = "Close tab" })

map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Lazy" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<CR>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<CR>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader>xq", function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end, { desc = "Open Quickfix List" })

map("n", "<leader>ls", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
  pcall(vim.diagnostic.disable, bufnr)
  vim.opt_local.spell = false
end, { desc = "Stop all heavy lifting" })

map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "Lsp Info" })
map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Lsp Restart" })
map("n", "<leader>ld", "<cmd>LspLog<CR>", { desc = "Lsp Log" })

map("n", "<leader>cbf", "<cmd>Dispatch bob/bob -q format<CR>", { desc = "Format" })
map("n", "<leader>cbl", "<cmd>Dispatch bob/bob -q lint-test<CR>", { desc = "Lint Test" })
map("n", "<leader>cbu", "<cmd>Dispatch bob/bob -q unit-test<CR>", { desc = "Unit Test" })
map("n", "<leader>cbb", "<cmd>Dispatch bob/bob clean init build<CR>", { desc = "Build" })
map("n", "<leader>cbp", "<cmd>Dispatch bob/bob -q pre-integration-test<CR>", { desc = "Publish to Sandbox" })
map("n", "<leader>.", [['<esc>' . repeat('.', v:count1)]], { desc = "Repeat cgn", expr = true })
map("c", "<C-v>", "<C-r>*")
-- map("i", "<C-r>", "<C-v>")
map("i", "<C-v>", "<C-r>+")
map("n", "<C-c>", '"+y')
map("v", "<C-c>", '"+y')
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")
map("v", "*", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>n]], { silent = true })
map("v", "#", [[y:let @/=substitute(escape(@",'.$*[^\/~'),'\n','\\n','g')<CR>N]], { silent = true })
map("n", ",", "@q")

vim.cmd([[
  set wildcharm=<C-Z>
  cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
  cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
  cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
  cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"
  cnoremap <expr> <Tab>   getcmdtype() =~ '[\/?]' ? "<C-g>" : "<C-z>"
  cnoremap <expr> <S-Tab> getcmdtype() =~ '[\/?]' ? "<C-t>" : "<S-Tab>"
  " start of line
  cnoremap <C-A>  <Home>
  " back one character
  cnoremap <C-B>  <Left>
  " delete character under cursor
  cnoremap <C-D>  <Del>
  " end of line
  cnoremap <C-E>  <End>
  " forward one character
  cnoremap <C-F>  <Right>
  " recall newer command-line
  cnoremap <C-N>  <Down>
  " recall previous (older) command-line
  cnoremap <C-P>  <Up>
  " back one word
  cnoremap <Esc><C-B> <S-Left>
  " forward one word
  cnoremap <Esc><C-F> <S-Right>
]])

map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix item" })
map("n", "[q", vim.cmd.cprev, { desc = "Prev Quickfix item" })
