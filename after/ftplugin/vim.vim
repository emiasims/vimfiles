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
inoremap <buffer> <C-v><Tab> <lt>Tab>
inoremap <buffer> <C-v><Cr> <lt>Cr>

xmap <buffer> af :normal [[V][<Cr>
xmap <buffer> if :normal [[jV][k<Cr>
omap <buffer> af :normal [[V][<Cr>
omap <buffer> if :normal [[jV][k<Cr>

nmap go ][o<Cr>fun<Tab>
nmap gO [[O<Cr><Up>fun<Tab>

nnoremap <silent> <expr> <buffer> K ':help ' . expand('<cword>') . ((expand('<cWORD>') =~# expand('<cword>') . '(') ? "(\<Cr>" : "\<Cr>")

nmap \t <Plug>(testing-goto)
nmap \r [[Wyiw:TestOrg <C-r>"<Cr>

command! -buffer If2Ternary call vim#if2tern()
command! -buffer Ternary2If call vim#tern2if()
command! -range=% -buffer SortVimFuncs call vim#sortfunctions()

inoreabbrev <buffer> tbool v:t_bool
inoreabbrev <buffer> tdict v:t_dict
inoreabbrev <buffer> tflt v:t_float
inoreabbrev <buffer> tfunc v:t_func
inoreabbrev <buffer> tlist v:t_list
inoreabbrev <buffer> tnum v:t_number
inoreabbrev <buffer> tstr v:t_string

" The only place I will consistently want a "" is if I do let something = ""
Contextualize {-> getline('.')[:col('.') - 2] =~? '=\s*$'} inoremap <buffer> " ""<C-g>U<Left>
