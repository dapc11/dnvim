local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end
-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map({ "n", "v", "x", "o" }, "<C-d>", "<C-d>zz")
map({ "n", "v", "x", "o" }, "<C-u>", "<C-u>zz")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

map("n", "zv", "zMzvzz", { desc = "Close all folds except current one" })
map("n", "z<Down>", "zcjzOzz", { desc = "Close current fold and open next" })
map("n", "z<Up>", "zckzOzz", { desc = "Close current fold and open previous" })

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
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
map("n", "<S-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<S-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<S-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
map("n", "Q", ":tabclose<cr>", { desc = "Close tab" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "ä<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "ö<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

map(
  "n",
  "<leader>Ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

map("n", "öd", vim.diagnostic.goto_prev)
map("n", "äd", vim.diagnostic.goto_next)

-- Close all buffers if needed to refresh speed
map("n", "<leader>bo", "<cmd>%bd!|e#<cr>", { desc = "Close all buffers but the current one" }) -- https://stackoverflow.com/a/42071865/516188
