for key, val in pairs({
	tabstop = 4,
	softtabstop = 4,
	shiftwidth = 4, -- 4 spaces
	shiftround = true, -- Round tabs to multiplier of shiftwicth
	smartindent = true,
	ignorecase = true,
	expandtab = true, -- In Insert mode: Use the appropriate number of spaces to insert a tab
	relativenumber = true, -- relative line numbers to current line
	cursorline = true, -- Highlgiht cursor line
	hlsearch = true, -- Highlight search
	hidden = true,
	errorbells = false, -- No sound on error
	nu = true, -- Line numbers
	wrap = false,
	swapfile = false,
	backup = false,
	undodir = os.getenv("HOME") .. "/.vim/undodir",
	undofile = true,
	incsearch = true, -- Evolve search as I write
	termguicolors = true, -- Make colorscheme work
	scrolloff = 8, -- Start scroll when n lines from screen edge
	showmode = false,
	colorcolumn = "100", -- Dont go further
	updatetime = 50, -- Short time to combo key strokes
	mouse = "a", -- Enable mouse
	autoread = true,
	completeopt = "menu,menuone,noselect",
	shortmess = vim.o.shortmess .. "c",
	clipboard = vim.o.clipboard .. "unnamedplus", -- System clipboard
	pumheight = 15, -- height of popup menu
	splitbelow = true,
	splitright = true,
}) do
	vim.o[key] = val
end

for key, val in pairs({
	mapleader = " ",
	indent_blankline_use_treesitter = true,
	indent_blankline_show_first_indent_level = true,
	indent_blankline_filetype_exclude = { "help" },
	indentLine_setConceal = 0,
}) do
	vim.g[key] = val
end

vim.bo.matchpairs = "(:),{:},[:],<:>"
vim.cmd([[
set path+=**
nnoremap <SPACE> <Nop>

function! HighlightTodo()
match none
match Todo /TODO/
endfunc

set background=dark
colorscheme onedark

augroup dapc
autocmd!
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline
autocmd BufNewFile,BufRead *.tpl set filetype=gotmpl
" Yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd BufReadPost,BufNewFile * :call HighlightTodo()

autocmd FileType yaml,gitcommit lua vim.diagnostic.disable()
autocmd FileType yaml,gitcommit lua vim.diagnostic.hide()
augroup END

au TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=250, on_visual=true}
]])

local signs = {
	{
		name = "DiagnosticSignError",
		text = "",
		type = "Error",
	},
	{
		name = "DiagnosticSignWarn",
		text = "",
		type = "Warn",
	},
	{
		name = "DiagnosticSignHint",
		text = "",
		type = "Hint",
	},
	{
		name = "DiagnosticSignInfo",
		text = "",
		type = "Info",
	},
}

for _, sign in ipairs(signs) do
	local hl = "DiagnosticLineNr" .. sign.type
	vim.fn.sign_define(sign.name, {
		texthl = sign.name,
		text = sign.text,
		numhl = hl,
	})
end

vim.g.rooter_pattern = {
	"ruleset2.0.yaml",
	"pom.xml",
	".git",
	"Makefile",
	"_darcs",
	".hg",
	".bzr",
	".svn",
	"node_modules",
	"CMakeLists.txt",
}

-- Bracketed paste
vim.cmd([[
" Code from:
" http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
" then https://coderwall.com/p/if9mda
" and then https://github.com/aaronjensen/vimfiles/blob/59a7019b1f2d08c70c28a41ef4e2612470ea0549/plugin/terminaltweaks.vim
" to fix the escape time problem with insert mode.
"
" Docs on bracketed paste mode:
" http://www.xfree86.org/current/ctlseqs.html
" Docs on mapping fast escape codes in vim
" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

if exists("g:loaded_bracketed_paste")
    finish
endif
let &t_ti .= "\<Esc>[?2004h"
let g:loaded_bracketed_paste = 1

let &t_te = "\e[?2004l" . &t_te

function! XTermPasteBegin(ret)
    set pastetoggle=<f29>
    set paste
    return a:ret
endfunction

execute "set <f28>=\<Esc>[200~"
execute "set <f29>=\<Esc>[201~"
map <expr> <f28> XTermPasteBegin("i")
imap <expr> <f28> XTermPasteBegin("")
vmap <expr> <f28> XTermPasteBegin("c")
cmap <f28> <nop>
cmap <f29> <nop>
function! TabMessage(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    " use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    tabnew
    setlocal filetype=text bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction
command! -nargs=+ -complete=command TabMessage call TabMessage(<q-args>)
autocmd BufNewFile,BufRead * if search('{{.*}}', 'nw') | setlocal filetype=gotmpl | endif
]])
