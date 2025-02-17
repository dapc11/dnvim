local map = require("util").map

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<CR><esc>", { desc = "Escape and clear hlsearch" })

map("n", "<C-z>", "<cmd>set wrap!<cr>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "*", "*Nzz")
map("n", "#", "#nzz")
map("n", "g*", "g*zz")

map("n", "<leader>xd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

-- Note to self: c is for usage in motion dö, dä
map({ "n", "v", "c" }, "ö", "{")
map({ "n", "v", "c" }, "ä", "}")

map("n", "Y", "y$")
map("v", "p", [["_dP]])
map("n", "<leader>xr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace", silent = false })
map("v", "<leader>xr", [["hy:%s#<C-r>h##gc<left><left><left>]], { desc = "Replace", silent = false })
map("v", "<leader>xR", [[:s###gc<left><left><left><left>]], { desc = "Replace", silent = false })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })

-- better indenting
map("n", "<tab>", "==")
map("v", "<tab>", "==")
map("i", "<tab>", "<c-t>")
map("i", "<s-tab>", "<c-d>")
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
map("n", "<C-Down>", "}")
map("n", "<C-Up>", "{")

-- Move Lines
map("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move down" })
map("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move up" })
map("i", "<S-Down>", "<esc><cmd>m .+1<CR>==gi", { desc = "Move down" })
map("i", "<S-Up>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move up" })
map("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move up" })

map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Lazy" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<CR>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<CR>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader>x<right>", "<cmd>cnewer<CR>", { desc = "Next Quickfix List" })
map("n", "<leader>x<left>", "<cmd>colder<CR>", { desc = "Previous Quickfix List" })
map("n", "<leader>xl", "<cmd>chi<CR>", { desc = "List Quickfix Lists" })
map("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open Quickfix List" })

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
  " back one word
  cnoremap <Esc><C-B> <S-Left>
  " forward one word
  cnoremap <Esc><C-F> <S-Right>

  cnoremap <F2> \(.*\)
  inoremap <M-BS> <C-W>
  cnoremap <M-BS> <C-W>
]])

map("n", "]q", function()
  vim.cmd.cnext()
  vim.cmd("norm! zz")
end, { desc = "Next Quickfix item" })
map("n", "[q", function()
  vim.cmd.cprev()
  vim.cmd("norm! zz")
end, { desc = "Prev Quickfix item" })

local function open_CVE_in_browser()
  local cve = string.match(vim.fn.getline("."), "CVE%-%d+%-%d+")
  if cve then
    vim.fn.jobstart({ "xdg-open", "https://nvd.nist.gov/vuln/detail/" .. cve }, { detach = true })
  else
    print("No CVE found in the current line.")
  end
end

vim.keymap.set("n", "gv", open_CVE_in_browser, { desc = "Goto CVE Definition" })

local nav = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

local function navigate(dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)
    local pane = vim.env.WEZTERM_PANE
    if pane and win == vim.api.nvim_get_current_win() then
      local pane_dir = nav[dir]
      vim.fn.system("wezterm cli activate-pane-direction " .. pane_dir)
    end
  end
end

-- Move to window using the movement keys
for key, dir in pairs(nav) do
  vim.keymap.set("n", "<M-" .. dir .. ">", navigate(key))
end

map("n", "<leader>zf", function()
  Snacks.picker.grep({ cwd = "~/notes/", path_shorten = true })
end, { noremap = true, silent = true, desc = "Search in Notes" })
map("n", "<leader>zb", function()
  Snacks.picker.files({ cwd = "~/notes/", path_shorten = true })
end, { noremap = true, silent = true, desc = "Browse Notes" })
map("n", "<leader>zn", function()
  require("util").create_note()
end, { noremap = true, silent = true, desc = "New Note" })

local function toggle_sub_magic()
  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()
  local pattern = "^(%%s/)(.*)$"
  local before, after = cmdline:match(pattern)
  if before and after then
    local search_end = after:find("/")
    if not search_end then
      return
    end
    local search_term = after:sub(1, search_end - 1)
    local replace_and_flags = after:sub(search_end)

    if search_term:sub(1, 2) == "\\v" then
      search_term = after:sub(2, search_end - 1)
      search_term = search_term:sub(3, -2)
      cmdpos = cmdpos - 4
    else
      search_term = "\\v(" .. search_term .. ")"
      cmdpos = cmdpos + 4
    end

    local new_cmdline = before .. search_term .. replace_and_flags
    vim.fn.setcmdline(new_cmdline, cmdpos)
    vim.schedule(function()
      vim.api.nvim_input("<space><BS>")
    end)
  end
end

local function toggle_sub_flag(flag_to_toggle)
  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()
  local pattern = "^(%%s/.-/)(.*)(/[gci]*)$"
  local before, middle, flags = cmdline:match(pattern)

  if before and middle then
    local new_flags = ""
    local flag_set = {}

    for flag in (flags or ""):gmatch("%a") do
      flag_set[flag] = true
    end

    flag_set[flag_to_toggle] = not flag_set[flag_to_toggle]

    for _, flag in ipairs({ "g", "c", "i" }) do
      if flag_set[flag] then
        new_flags = new_flags .. flag
      end
    end

    local new_cmdline = before .. middle .. (new_flags ~= "" and "/" .. new_flags or "")
    vim.fn.setcmdline(new_cmdline, cmdpos)

    vim.schedule(function()
      vim.api.nvim_input("<space><BS>")
    end)
  end
end

vim.keymap.set("v", "<leader>xr", function()
  local temp_keymaps = {
    { lhs = "<S-CR>", rhs = "<CR>a" },
    {
      lhs = "<A-m>",
      rhs = toggle_sub_magic,
    },
    {
      lhs = "<A-g>",
      rhs = function()
        toggle_sub_flag("g")
      end,
    },
    {
      lhs = "<A-c>",
      rhs = function()
        toggle_sub_flag("c")
      end,
    },
    {
      lhs = "<A-i>",
      rhs = function()
        toggle_sub_flag("i")
      end,
    },
  }
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")

  for _, keymap in ipairs(temp_keymaps) do
    vim.keymap.set("c", keymap.lhs, keymap.rhs, opts)
  end

  vim.api.nvim_input(":<C-u>" .. "%s/\\v(" .. text .. ")//gci<Left><Left><Left><Left>")

  local augroup = vim.api.nvim_create_augroup("substitute", { clear = true })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    pattern = "*",
    once = true,
    callback = function()
      for _, keymap in ipairs(temp_keymaps) do
        vim.api.nvim_del_keymap("c", keymap.lhs)
      end
    end,
  })
end, { noremap = true, silent = true, desc = "substitute with visual selection" })
