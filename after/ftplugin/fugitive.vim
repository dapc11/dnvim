nmap <silent><buffer> q :tabclose<CR>
nmap <silent><buffer> <Tab> =
nmap <silent><buffer> o gO
nmap <silent><buffer> k X
nmap <silent><buffer> gpr :Git fetch \| Git rebase origin/master<CR>
nmap <silent><buffer> gps :Git submodule update --init --recursive<CR>

nnoremap <silent><buffer> gpg :Git push origin HEAD:refs/for/master

nmap <buffer> >c [c
nmap <buffer> <c ]c
nmap <buffer> >/ [/
nmap <buffer> </ ]/
nmap <buffer> >f [m
nmap <buffer> <f ]m
nmap <buffer> >> [[
nmap <buffer> << ]]
