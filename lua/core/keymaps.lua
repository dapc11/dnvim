-- Fuzzy find
map("n", "<leader>m", ':lua require("telescope.builtin").keymaps()<CR>', { desc = "Find keymap" })
map("n", "<leader>h", ':lua require("telescope.builtin").oldfiles()<CR>', { desc = "Find file in history" })
map("n", "<Leader>n", ':lua require("telescope.builtin").git_files()<CR>', { desc = "Find Git file" })
map(
  "n",
  "<Leader>N",
  ':lua require("telescope.builtin").git_files({git_command={"git","ls-files","--modified","--exclude-standard"}})<CR>',
  { desc = "Find modified Git file" }
)
map(
  "n",
  "<Leader>O",
  ':lua require("telescope.builtin").find_files({hidden = true, no_ignore = true, previewer = false})<CR>',
  { desc = "Find file (hidden and ignored included)" }
)
map("n", "<Leader>fw", ':lua require("telescope.builtin").grep_string()<CR>', { desc = "Find word under cursor" })
map("v", "s", '"zy:Telescope grep_string default_text=<C-r>z<cr>', { desc = "Find selection" })
map("n", "<Leader>rg", ':lua require("core.custom-finders").repo_grep()<CR>', { desc = "Grep in repos" })
map("n", "<Leader>rf", ':lua require("core.custom-finders").repo_fd()<CR>', { desc = "Find file in repos" })
map("n", "<Leader>ss", ':lua require("core.custom-finders").spell_check()<CR>', { desc = "Spell check" })
map(
  "n",
  "<Leader>o",
  ':lua require("telescope.builtin").find_files({path_display={"absolute"}, previewer = false})<CR>',
  { desc = "Find file" }
)
map(
  "n",
  "<Leader>ff",
  ':lua require("telescope.builtin").find_files({cwd = "~/repos/", path_display={"truncate", shorten = {len = 3, exclude = {1,-1}}}})<CR>',
  { desc = "Find repos file" }
)
map(
  "n",
  "<leader><leader>",
  ':lua require("telescope.builtin").live_grep({path_display={"truncate", shorten = {len = 3, exclude = {1,-1}}}})<CR>',
  { desc = "Grep in cwd" }
)
map("n", "<C-p>", ":Telescope projects<CR>", { desc = "Find project" })
map("n", "<C-f>", ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>', { desc = "Find in buffer" })
map("n", "<C-j>", ':lua require("telescope.builtin").jumplist()<CR>', { desc = "Find jump list" })

-- Harpoon
map("n", "<A-m>", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add current buffer to Harpoon" })
map("n", "<A-l>", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", { desc = "Harpoon list" })
map("n", "<A-1>", ":lua require('harpoon.ui').nav_file(1)<CR>", { desc = "First entry" })
map("n", "<A-2>", ":lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Second entry" })
map("n", "<A-3>", ":lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Third entry" })
map("n", "<A-4>", ":lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Fourth entry" })

-- Git
map("n", "<leader>gp", ":Git push origin HEAD:refs/for/master<CR>", { desc = "Push Gerrit" })
map("n", "<leader>gP", ":Git push<CR>", { desc = "Push" })
map("n", "<C-g>", ":Neogit<CR>", { desc = "Toggle Git status" })
map("n", "<leader>gg", ":Neogit<CR>", { desc = "Status" })
map("n", "<leader>gt", ":!alacritty &<CR>", { desc = "Terminal" })
map("n", "<leader>gc", ":Telescope git_commits<CR>", { desc = "Commits" })

-- Misc
map("n", "<SPACE>", "<Nop>")
map("n", "<F1>", "<Nop>")

-- Profiling
map(
  "n",
  "<Leader>zp",
  ":profile start nvim-profile.log | profile func * | profile file *",
  { desc = "Start profiling" }
)

map("v", "ä", "}", { desc = "Next section" })
map("v", "ö", "{", { desc = "Previous section" })
map("n", "ä", "}", { desc = "Next section" })
map("n", "ö", "{", { desc = "Previous section" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit insert mode terminal" })
-- Don't copy the replaced text after pasting in visual mode
map("v", "p", '"_dP', { desc = "Paste" })
-- Don't copy the replaced text after changing in visual mode
map("v", "c", '"_c')
map("v", "c", '"_c')

map("n", "<Leader>q", "<c-w>q<CR>", { desc = "Save and quit buffer" })
map("n", "<C-q>", ":bdelete<CR>", { desc = "Save and quit buffer" })
map("n", "<Leader>Q", ":qa<CR>", { desc = "Quit" })
map("n", "Qa", ":qa<CR>", { desc = "Quit" })
map("n", "W", ":noautocmd w<CR>", { desc = "Save without format" })

-- Commandline
map("c", "<C-a>", "<Home>", { desc = "Beginning of line" })
map("c", "<C-e>", "<End>", { desc = "End of line" })
map("c", "<M-Left>", "<S-Left>", { desc = "Navigate to previous word" })
map("c", "<M-Right>", "<S-Right>", { desc = "Navigate to next word" })
map("c", "<M-BS>", "<C-W>", { desc = "Remove whole word" })
map("c", "<C-BS>", "<C-W>", { desc = "Remove whole word" })

-- Paste without overwrite default register
map("x", "p", "pgvy", { desc = "Paste without overwriting default reg" })

-- Center search results
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

map("n", "m", ':<C-U>lua require("tsht").nodes()<CR>', { desc = "Normal mode select nodes" })
map("v", "m", ':lua require("tsht").nodes()<CR>', { desc = "Visual mode select nodes" })

map("n", "<C-Left>", "<C-W>h", { desc = "Navigate to left pane" })
map("n", "<C-Down>", "<C-W>j", { desc = "Navigate to bottom pane" })
map("n", "<C-Up>", "<C-W>k", { desc = "Navigate to top pane" })
map("n", "<C-Right>", "<C-W>l", { desc = "Navigate to right pane" })
map("n", "<S-Right>", ":tabnext<CR>", { desc = "Next tab" })
map("n", "<S-Left>", ":tabprevious<CR>", { desc = "Previous tab" })
map("n", "<M-Right>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<M-Left>", ":bprev<CR>", { desc = "Previous buffer" })
map("n", "<leader>ch", "<cmd>nohlsearch<CR>", { desc = "Clean highlights" })

map("n", "<S-Down>", ":m .+1<CR>==", { desc = "Shift line down" })
map("n", "<S-Up>", ":m .-2<CR>==", { desc = "Shift line up" })
map("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Shift selected lines down" })
map("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Shift selected lines up" })

map("i", "<C-a>", "<home>", { desc = "Beginning of line", noremap = false })
map("i", "<C-e>", "<end>", { desc = "End of line", noremap = false })

map("i", "<C-v>", "<esc>pa", { desc = "Paste", noremap = false })
map("c", "<C-v>", "<C-r>0", { desc = "Paste", noremap = false })

map("n", "<A-a>", "<C-a>", { desc = "Increment number" })
map("v", "<A-a>", "<C-a>", { desc = "Increment number" })
map("n", "<A-x>", "<C-x>", { desc = "Decrement number" })
map("v", "<A-x>", "<C-x>", { desc = "Decrement number" })

vim.cmd([[
    " Sane navigation in command mode
    "set wildcharm=<C-Z>
    "cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    "cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
    "cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
    "cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

    """""""" Clear quickfix list
    function ClearQuickfixList()
        call setqflist([])
        cclose
    endfunction
    command! ClearQuickfixList call ClearQuickfixList()
]])
map("n", "<leader>zz", ":ClearQuickfixList<CR>", { desc = "Clear qf" })
map("n", "<leader>zl", ":nohlsearch<CR>:diffupdate<CR>:syntax sync fromstart<CR><c-l>", { desc = "Clear highlights" })
if _G.plugins.hop then
  map(
    "n",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>"
  )
  map(
    "n",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>"
  )
  map(
    "o",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<CR>"
  )
  map(
    "o",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<CR>"
  )
  map(
    "",
    "t",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>"
  )
  map(
    "",
    "T",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>"
  )
end

map("n", "<C-e>", ":NvimTreeToggle<CR>", { desc = "Toggle explorer" })
map("n", "<leader>cd", "<cmd>lua vim.diagnostic.disable()<CR>", { desc = "Disable diagnostics" })
map("n", "<leader>ce", "<cmd>lua vim.diagnostic.enable()<CR>", { desc = "Enable diagnostics" })

map("i", "<C-E>", "<Plug>luasnip-next-choice", { desc = "Next choice" })
map("s", "<C-E>", "<Plug>luasnip-next-choice", { desc = "Next choice" })

map("x", "ga", ":EasyAlign<CR>", { desc = "Align" })
map("n", "ga", ":EasyAlign<CR>", { desc = "Align" })
map("n", "<Tab>", "<C-t>", { desc = "Increase indentation" })
map("n", "<S-Tab>", "<C-d>", { desc = "Decrease indentation" })
map("v", "<Tab>", ">gv", { desc = "Increase indentation" })
map("v", "<S-Tab>", "<gv", { desc = "Decrease indentation" })
map("i", "<S-Tab>", "<C-d>", { desc = "Decrease indentation" })
map("n", "<q", ":cnext<CR>", { desc = "Next in qf" })
map("n", ">q", ":cprevious<CR>", { desc = "Prev in qf" })
map("n", "<l", ":lnext<CR>", { desc = "Next in lf" })
map("n", ">l", ":lprevious<CR>", { desc = "Prev in lf" })
map("n", "<C-b>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
map("v", "<M-k>", "<Cmd>lua require('dapui').eval()<CR>", { desc = "Evaluate expression" })

-- Packer
map("n", "<leader>ps", ":PackerSync<CR>", { desc = "Sync" })
map("n", "<leader>pc", ":PackerCompile<CR>", { desc = "Compile" })
map("n", "<leader>pl", ":PackerClean<CR>", { desc = "Clean" })

vim.cmd([[
function! JiraSearch()
     silent! exec "silent! !google-chrome \"https://eteamproject.internal.ericsson.com/browse/" . @j . "\" &"
endfunction
function! UrlEncode(string)
    let result = ""
    let characters = split(a:string, '.\zs')
    for character in characters
        if character == " "
            let result = result . "+"
        elseif CharacterRequiresUrlEncoding(character)
            let i = 0
            while i < strlen(character)
                let byte = strpart(character, i, 1)
                let decimal = char2nr(byte)
                let result = result . "%" . printf("%02x", decimal)
                let i += 1
            endwhile
        else
            let result = result . character
        endif
    endfor
    return result
endfunction

" Returns 1 if the given character should be percent-encoded in a URL encoded
" string.
function! CharacterRequiresUrlEncoding(character)

    let ascii_code = char2nr(a:character)
    if ascii_code >= 48 && ascii_code <= 57
        return 0
    elseif ascii_code >= 65 && ascii_code <= 90
        return 0
    elseif ascii_code >= 97 && ascii_code <= 122
        return 0
    elseif a:character == "-" || a:character == "_" || a:character == "." || a:character == "~"
        return 0
    endif

    return 1

endfunction

function! GoogleSearch()
   let searchterm = getreg("g")
   let searchterm = substitute(searchterm, "\n", " ", "g")
   let searchterm = UrlEncode(searchterm)
   let searchterm = shellescape(searchterm, 1)
   silent! exec "!google-chrome 'https://google.com/search?q=" . searchterm . "' &"
   redraw!
endfunction
]])
map("n", "<leader>fg", 'b"gye:call GoogleSearch()<CR>', { desc = "Google word under cursor" })
map("v", "<leader>fj", "jy<Esc>:call JiraSearch()<CR>", { desc = "Open Jira ticket" })
map("v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "Search and replace selection" })

vim.cmd([[
if has("unix")
    map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
else
    map ,e :e <C-R>=expand("%:p:h") . "\" <CR>
endif
]])

map("n", "<leader>tc", '<cmd>lua require("neotest").run.run()<CR>', { desc = "Run nearest test" })
map("n", "<leader>tf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = "Run current file" })
map("n", "<leader>td", '<cmd>lua require("neotest").run.run({ strategy = "dap" })<CR>', { desc = "Debug nearest test" })
map("n", "<leader>tl", '<cmd>lua require("neotest").run.run_last()<CR>', { desc = "Re-run last" })
map(
  "n",
  ">t",
  '<cmd>lua require("neotest").jump.prev({ status = "failed" })<CR>',
  { silent = true, desc = "Jump to previous failed test" }
)
map(
  "n",
  "<t",
  '<cmd>lua require("neotest").jump.next({ status = "failed" })<CR>',
  { silent = true, desc = "Jump to next failed test" }
)
map("n", "<leader>ts", '<cmd>lua require("neotest").summary.toggle()<CR>', { desc = "Toggle test summary" })
map("n", "<leader>to", '<cmd>lua require("neotest").output.open({ enter = true })<CR>', { desc = "Open test output" })

map("n", "<leader>zn", ":%s/\\\\n/\\r/g", { desc = "Fix new lines", silent = false })
