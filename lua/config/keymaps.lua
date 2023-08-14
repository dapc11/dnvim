-- Unimpaired
vim.cmd([[
nmap > [
nmap < ]
omap > [
omap < ]
xmap > [
xmap < ]
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> Qa ((getcmdtype() is# ':' && getcmdline() is# 'Qa')?('qa'):('Qa'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]])
-- End Unimpaired

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end
map("n", "<leader>v", "<C-W>v", { desc = "Split window right", remap = true })
map({ "n", "v", "x", "o" }, "ä", "}zz")
map({ "n", "v", "x", "o" }, "ö", "{zz")
map({ "n", "v", "x", "o" }, "<C-d>", "<C-d>zz")
map({ "n", "v", "x", "o" }, "<C-u>", "<C-u>zz")

map("n", "zv", "zMzvzz", { desc = "Close all folds except current one" })

map("n", "z<Down>", "zcjzOzz", { desc = "Close current fold and open next" })

map("n", "z<Up>", "zckzOzz", { desc = "Close current fold and open previous" })

map("n", "W", ":noautocmd w<CR>")

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

-- stylua: ignore
local function getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end
map("n", "<C-f>", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Find in Current Buffer", remap = true })
map("v", "<C-f>", function()
  require("telescope.builtin").current_buffer_fuzzy_find({ default_text = getVisualSelection() })
end, { desc = "Current Buffer Grep Selection" })
map("n", "<leader>fp", function()
  require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
end, { desc = "Find Plugin File" })
map("n", "<leader>r", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Find Recent Files" })
map("n", "<leader><leader>", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live Grep" })
map("v", "<leader><leader>", function()
  require("telescope.builtin").live_grep({ default_text = getVisualSelection() })
end, { desc = "Live Grep Selection" })

map("n", "<leader>gb", require("telescope.builtin").git_branches, { desc = "branches" })
map("n", "<leader>n", require("telescope.builtin").git_files, { desc = "Find Tracked Files" })
map("n", "<leader>N", function()
  require("telescope.builtin").git_files({ git_command = { "git", "ls-files", "--modified", "--exclude-standard" } })
end, { desc = "Find Untracked Files" })
map("n", "<leader>fn", "<CMD>Telescope notify<cr>", { desc = "Notifications" })
map("n", "<C-p>", "<cmd>Telescope projects<cr>", { desc = "Find Project" })

map(
  "n",
  "<leader>Ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)
