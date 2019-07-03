setlocal foldmethod=marker
setlocal formatoptions=1jcr
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal iskeyword+=:
setlocal colorcolumn=100
setlocal tabstop=2
setlocal shiftwidth=2
setlocal textwidth=99
setlocal expandtab
let b:autopairs_skip = ['"']

inoremap <buffer> <C-l> <C-o>bl:<C-o>e<Right>
