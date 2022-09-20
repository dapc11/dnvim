local opt = vim.opt
local g = vim.g

opt.autoread = true
opt.backup = false
opt.clipboard = vim.o.clipboard .. "unnamedplus" -- System clipboard
opt.colorcolumn = "100" -- Dont go further
opt.completeopt = {"menuone","noselect"} -- mostly just for cmp
opt.cursorline = true -- Highlgiht cursor line
opt.errorbells = false -- No sound on error
opt.expandtab = true -- In Insert mode: Use the appropriate number of spaces to insert a tab
opt.hidden = true
opt.hlsearch = true -- Highlight search
opt.ignorecase = true
opt.incsearch = true -- Evolve search as I write
opt.mouse = "a" -- Enable mouse
opt.nu = true -- Line numbers
opt.pumheight = 10 -- height of popup menu
opt.relativenumber = true -- relative line numbers to current line
-- opt.scrolloff = 8 -- Start scroll when n lines from screen edge
opt.shiftround = true -- Round tabs to multiplier of shiftwicth
opt.shiftwidth = 4 -- 4 spaces
opt.shortmess:append("c")
opt.showmode = false
opt.smartindent = true
opt.softtabstop = 4
opt.splitbelow = true
opt.wildmenu = false
opt.splitright = true
opt.swapfile = false
opt.tabstop = 4
opt.termguicolors = true -- Make colorscheme work
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true
opt.updatetime = 50 -- Short time to combo key strokes
opt.wrap = false
opt.whichwrap:append("<>[]hl")

g.mapleader = " "
g.do_filetype_lua = 1
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_first_indent_level = true
g.indent_blankline_filetype_exclude = { "help" }
g.indentLine_setConceal = 0
g.registers_window_border = "single"

vim.bo.matchpairs = "(:),{:},[:],<:>"
vim.cmd([[
set path+=**
nnoremap <SPACE> <Nop>

if executable("rg")
  set grepprg=rg\ --vimgrep
endif
]])
vim.g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha

require("catppuccin").setup()

vim.cmd([[
  set background=dark
  colorscheme catppuccin
]])

-- Bracketed paste
-- Code from:
-- http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
-- then https://coderwall.com/p/if9mda
-- and then https://github.com/aaronjensen/vimfiles/blob/59a7019b1f2d08c70c28a41ef4e2612470ea0549/plugin/terminaltweaks.vim
-- to fix the escape time problem with insert mode.
--
-- Docs on bracketed paste mode:
-- http://www.xfree86.org/current/ctlseqs.html
-- Docs on mapping fast escape codes in vim
-- http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim
vim.cmd([[
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
]])

--}}}
