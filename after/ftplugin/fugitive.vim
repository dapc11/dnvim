setlocal colorcolumn=0
nmap <silent><buffer> q :tabclose<CR>
nmap <silent><buffer> <Tab> =
nmap <silent><buffer> o gO
nmap <silent><buffer> k X
nmap <buffer> >c [c
nmap <buffer> <c ]c
nmap <buffer> >/ [/
nmap <buffer> </ ]/
nmap <buffer> >f [m
nmap <buffer> <f ]m
nmap <buffer> >> [[
nmap <buffer> << ]]

function! GitNavDown()
  let pos = getpos('.')
  silent! normal! ]m
  if getpos('.') == pos
    silent! normal! ]/
  endif
endfunction

function! GitNavUp()
  let pos = getpos('.')
  silent! normal! [m
  if getpos('.') == pos
    silent! normal! [/
  endif
endfunction

nmap <silent><buffer> <C-Down> ]m
nmap <silent><buffer> <C-Up> [m

nnoremap <buffer> R :!git fetch && git rebase origin/$(git rev-parse --abbrev-ref HEAD)<CR>
nmap <buffer> F :Git fetch<CR>
nmap <silent><buffer> L :Git log --graph --pretty=format:'%h %cs %s <%an>%d' --abbrev-commit<CR>
nmap <buffer> S :Git submodule update --init --recursive<CR>

