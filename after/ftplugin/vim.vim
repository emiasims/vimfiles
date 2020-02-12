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

inoremap <silent> <buffer> <C-l> <C-o>:call feedkeys('<C-o>b' . nr2char(getchar()) . ":<C-o>e\<Right<Right>>")<Cr>

for i in range(97, 122)  " a-z, make <C-v><C-a> insert <C-a>.
  execute 'inoremap <buffer> <C-v><C-' . nr2char(i) . '> <lt>C-' . nr2char(i) . '>'
endfor
inoremap <buffer> <C-v><Esc> <lt>Esc>

xmap <buffer> af :normal [[V][<Cr>
xmap <buffer> if :normal [[jV][k<Cr>
omap <buffer> af :normal [[V][<Cr>
omap <buffer> if :normal [[jV][k<Cr>
