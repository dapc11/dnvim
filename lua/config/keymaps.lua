local map = require("util").map

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<CR><esc>", { desc = "Escape and clear hlsearch" })

map({ "i", "v", "n", "s" }, "<C-a>", "<C-u>", { desc = "Scroll up" })
map({ "n", "v" }, "ö", "{")
map({ "n", "v" }, "ä", "}")

map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

map("n", "zv", "zMzvzz", { desc = "Close all folds except current one" })
map("n", "z<Down>", "zcjzOzz", { desc = "Close current fold and open next" })
map("n", "z<Up>", "zckzOzz", { desc = "Close current fold and open previous" })

-- save file
map({ "i" }, "<C-s>", "<cmd>w<CR><esc>", { desc = "Save file" })
map("n", "W", "<cmd>noautocmd w<CR>")
--
-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>v", "<C-W>v", { desc = "Split window right", remap = true })

-- Move to window using the <ctrl> arrow keys
map("n", "<C-Left>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Move Lines
map("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move up" })
map("n", "Q", ":tabclose<CR>", { desc = "Close tab" })

map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<CR>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<CR>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<<tab>", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "><tab>", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })
map("n", ">q", "<cmd>cprevious<CR>", { desc = "Previous Quickfix" })
map("n", "<q", "<cmd>cnext<CR>", { desc = "Next Quickfix" })
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open Quickfix List" })
map(
  "n",
  "<leader>Ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

map("n", "<leader>cs", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.stop_client(vim.lsp.get_active_clients({ bufnr = bufnr }))
  pcall(vim.diagnostic.disable, bufnr)
  vim.opt_local.spell = false
  require("lualine").refresh()
end, { desc = "Stop all heavy lifting" })

-- Close all buffers if needed to refresh speed
map("n", "<leader>bo", "<cmd>%bd!|e#<CR>", { desc = "Close all buffers but the current one" }) -- https://stackoverflow.com/a/42071865/516188
map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "Lsp Info" })
map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Lsp Restart" })
map("n", "<leader>ld", "<cmd>LspLog<CR>", { desc = "Lsp Log" })
map("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Lazy" })

map("n", "<C-c>", "<cmd>normal! ciw<CR>a")
map("n", "§", "@:")
map("n", "<C-s>", function()
  vim.api.nvim_command("norm! yiw")
  vim.fn.setreg("/", vim.fn.getreg("+"))
  vim.api.nvim_feedkeys("ciw", "n", false)
end, { desc = "Search & Replace" })

map("v", "<C-s>", [[y/\V<C-R>=escape(@",'/\')<CR><CR>Ncgn]], { desc = "Search & Replace" })

map("n", "<g", function()
  require("treesitter-context").go_to_context()
end, { silent = true })

vim.cmd([[
  xnoremap <leader>cR y<cmd>let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')<CR>gvqi
  nnoremap ; gn@i
  map , @q

  nmap <c-c> "+y
  vmap <c-c> "+y
  vmap <tab> >gv
  vmap <s-tab> <gv
  inoremap <c-v> <c-r>+
  cnoremap <c-v> <c-r>+
  inoremap <c-r> <c-v>
]])
