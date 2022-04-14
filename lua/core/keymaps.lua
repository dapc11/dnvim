-- Fuzzy find
local function table_to_string(tbl)
	local result = "{"
	for k, v in pairs(tbl) do
		if type(k) == "string" then
			result = result .. '["' .. k .. '"]' .. "="
		end

		-- Check the value type
		if type(v) == "table" then
			result = result .. table_to_string(v)
		elseif type(v) == "boolean" then
			result = result .. tostring(v)
		else
			result = result .. '"' .. v .. '"'
		end
		result = result .. ","
	end
	-- Remove leading commas from the result
	if result ~= "" then
		result = result:sub(1, result:len() - 1)
	end
	return result .. "}"
end

local function get_find_files_source(path)
	local file = io.open(path, "r")
	local tbl = {}
	local i = 0
	if file then
		for line in file:lines() do
			i = i + 1
			tbl[i] = line
		end
		file:close()
	else
		tbl[0] = "~"
	end
	return table_to_string(tbl)
end

local telescope_open_hidden = get_find_files_source(os.getenv("HOME") .. "/telescope_open_hidden.txt")

map("n", "<leader>m", ':lua require("telescope.builtin").keymaps()<CR>')
map("n", "<leader>h", ':lua require("telescope.builtin").oldfiles()<CR>')
map("n", "<Leader>n", ':lua require("telescope.builtin").git_files()<CR>')
map(
	"n",
	"<Leader>N",
	':lua require("telescope.builtin").git_files({git_command={"git","ls-files","--modified","--exclude-standard"}})<CR>'
)
map(
	"n",
	"<Leader>O",
	':lua require("telescope.builtin").find_files({hidden = true, no_ignore = true, previewer = false})<CR>'
)
map("n", "<Leader>o", ':lua require("telescope.builtin").find_files({previewer = false})<CR>')
map(
	"n",
	"<Leader>f",
	':lua require("telescope.builtin").find_files({hidden = true, no_ignore = true, previewer = false, search_dirs = '
		.. telescope_open_hidden
		.. "})<CR>"
)
map(
	"n",
	"<leader><leader>",
	':lua require("telescope.builtin").live_grep({path_display={"truncate", shorten = {len = 3, exclude = {1,-1}}}})<CR>'
)
map("n", "<C-p>", ":Telescope projects<CR>")
map("n", "<C-f>", ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>')
map("n", "<C-j>", ':lua require("telescope.builtin").jumplist()<CR>')

-- Harpoon
map("n", "<A-m>", ":lua require('harpoon.mark').add_file()<CR>")
map("n", "<A-l>", ":lua require('harpoon.ui').toggle_quick_menu()<CR>")
map("n", "<A-1>", ":lua require('harpoon.ui').nav_file(1)<CR>")
map("n", "<A-2>", ":lua require('harpoon.ui').nav_file(2)<CR>")
map("n", "<A-3>", ":lua require('harpoon.ui').nav_file(3)<CR>")
map("n", "<A-4>", ":lua require('harpoon.ui').nav_file(4)<CR>")

-- Fugitive
map("n", "<leader>gs", ":Git<CR>")
map("n", "<leader>gl", ":Git log --stat<CR>")

-- Misc
map("n", "<SPACE>", "<Nop>")
map("n", "<F1>", "<Nop>")

-- Profiling
map("n", "<Leader>zp", ":profile start nvim-profile.log | profile func * | profile file *")

map("n", "ä", "<C-d>")
map("n", "ö", "<C-u>")
map("t", "<Esc>", "<C-\\><C-n>")
-- Don't copy the replaced text after pasting in visual mode
map("v", "p", '"_dP')
map("v", "c", '"_c')
map("v", "c", '"_c')

-- Requires gvim
-- Paste with shift+insert
map("n", "<Leader>Y", '"*y<CR>')
map("n", "<Leader>P", '"*p<CR>')
-- Paste with ctrl+v
map("n", "<Leader>y", '"+y<CR>')
map("n", "<Leader>p", '"+p<CR>')

-- Close buffer
map("n", "<Leader>q", "<c-w>q<CR>")
map("n", "<Leader>Q", ":qa<CR>")

-- Commandline
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<M-Left>", "<S-Left>")
map("c", "<M-Right>", "<S-Right>")
map("c", "<M-BS>", "<C-W>")
map("c", "<C-BS>", "<C-W>")

-- Paste without overwrite default register
map("x", "p", "pgvy")

-- Center search results
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "m", ':<C-U>lua require("tsht").nodes()<CR>')
map("v", "m", ':lua require("tsht").nodes()<CR>')

map("n", "<C-Left>", "<C-W>h")
map("n", "<C-Down>", "<C-W>j")
map("n", "<C-Up>", "<C-W>k")
map("n", "<C-Right>", "<C-W>l")

-- Shift lines up and down
map("n", "<S-Down>", ":m .+1<CR>==")
map("n", "<S-Up>", ":m .-2<CR>==")
map("v", "<S-Down>", ":m '>+1<CR>gv=gv")
map("v", "<S-Up>", ":m '<-2<CR>gv=gv")

-- Beginning and end of line
map("i", "<C-a>", "<home>", { noremap = false })
map("i", "<C-e>", "<end>", { noremap = false })

-- Control-V Paste in insert and command mode
map("i", "<C-v>", "<esc>pa", { noremap = false })
map("c", "<C-v>", "<C-r>0", { noremap = false })

-- Remap number increment to alt
map("n", "<A-a>", "<C-a>")
map("v", "<A-a>", "<C-a>")
map("n", "<A-x>", "<C-x>")
map("v", "<A-x>", "<C-x>")

vim.cmd([[
    " Sane navigation in command mode
    set wildcharm=<C-Z>
    cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
    cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
    cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

    """""""" Clear quickfix list
    function ClearQuickfixList()
        call setqflist([])
    endfunction
    command! ClearQuickfixList call ClearQuickfixList()
]])
map("n", "<leader>cc", ":ClearQuickfixList<CR>")
map("x", "ga", ":EasyAlign<CR>")
map("n", "ga", ":EasyAlign<CR>")
map("n", "<leader>l", ":nohlsearch<CR>:diffupdate<CR>:syntax sync fromstart<CR><c-l>")
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

map("n", "<C-t>", ":NvimTreeToggle<CR>")
map("n", "<leader>cd", "<cmd>lua vim.diagnostic.disable()<CR>")
map("n", "<leader>ce", "<cmd>lua vim.diagnostic.enable()<CR>")

map("i", "<C-E>", "<Plug>luasnip-next-choice")
map("s", "<C-E>", "<Plug>luasnip-next-choice")
map("n", "<Tab>", ":tabnext<CR>")
map("n", "<S-Tab>", ":tabprevious<CR>")

local opts = { noremap = true, silent = true }
map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
map("n", "<C-b>", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "<C-n>", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "<space>cq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
