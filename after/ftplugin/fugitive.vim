nmap <silent><buffer> q :tabclose<CR>
nmap <silent><buffer> <Tab> =
nmap <silent><buffer> o gO
nmap <silent><buffer> gpg :Git push origin HEAD:refs/for/master<CR>
nmap <silent><buffer> gpr :Git fetch \| Git rebase origin/master<CR>
nmap <silent><buffer> gps :Git submodule update --init --recursive<CR>
nmap <silent><buffer> gpp :Git push<CR>

nmap <buffer> >> [c
nmap <buffer> << ]c
nmap <buffer> >/ [/
nmap <buffer> </ ]/
nmap <buffer> >f [m
nmap <buffer> <f ]m
nmap <buffer> >s [[
nmap <buffer> <s ]]
