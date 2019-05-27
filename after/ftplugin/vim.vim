setlocal foldmethod=marker
setlocal formatoptions=1jcr
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal iskeyword+=:
setlocal colorcolumn=100

let b:autopairs_skip = ['"']

inoremap <buffer> <C-l> <C-o>bl:<C-o>e<Right>

" vim: set ts=2 sw=2 tw=99 et :
