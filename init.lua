local utils = require("core.utils")

utils.disabled_builtins()

utils.bootstrap()

utils.impatient()

-- Disable plugins
_G.plugins = {}
_G.plugins.hop = true

local sources = {
  "core.globals",
  "core.plugins",
  "core.options",
  "core.autocommands",
  "core.keymaps",
  "core.custom-theme",
  "core.custom-finders",
  "user.winbar",
}

for _, source in ipairs(sources) do
  local ok, err_msg = pcall(require, source)
  if not ok then
    error("Failed to load " .. source .. "\n\n" .. err_msg)
  end
end

vim.cmd([[
" using range-aware function
function! QFdelete(bufnr) range
    " get current qflist
    let l:qfl = getqflist()
    " no need for filter() and such; just drop the items in range
    call remove(l:qfl, a:firstline - 1, a:lastline - 1)
    " replace items in the current list, do not make a new copy of it;
    " this also preserves the list title
    call setqflist([], 'r', {'items': l:qfl})
    " restore current line
    call setpos('.', [a:bufnr, a:firstline, 1, 0])
    call cursor(a:firstline, 1)
endfunction

" using buffer-local mappings
" note: still have to check &bt value to filter out `:e quickfix` and such
augroup QFList | au!
    autocmd BufWinEnter quickfix if &bt ==# 'quickfix'
    autocmd BufWinEnter quickfix    nnoremap <silent><buffer>dd :call QFdelete(bufnr())<CR>
    autocmd BufWinEnter quickfix    vnoremap <silent><buffer>d  :call QFdelete(bufnr())<CR>
    autocmd BufWinEnter quickfix endif
augroup end
]])

vim.cmd([[
if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

if exists("g:neovide")
" Put anything you want to happen only in Neovide here
let g:neovide_transparency=0.95
let g:neovide_refresh_rate=60
let g:neovide_scroll_animation_length = 0.5
let g:neovide_underline_automatic_scaling = v:false
let g:neovide_cursor_animation_length=0
let g:neovide_cursor_trail_size=0.8
let g:neovide_floating_blur_amount_x = 2.0
let g:neovide_floating_blur_amount_y = 2.0
let g:winblend = 30
let g:pumblend = 30
set guifont=MesloLGS\ NF:h11
endif
]])
utils.compiled()
