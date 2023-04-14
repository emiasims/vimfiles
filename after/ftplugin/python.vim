setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldminlines=2
setlocal colorcolumn=100

command! -nargs=0 -buffer Outline lvimgrep /\v^\s*%(def |class )/ % | lopen

inoreabbrev <buffer> ipdb __import__('ipdb').set_trace()<Left><Esc>
inoreabbrev <buffer> pdb __import__('pdb').set_trace()<Left><Esc>
inoreabbrev <buffer> iem __import__('IPython').embed()<Left><Esc>

iabbrev <buffer> true True
iabbrev <buffer> false False
iabbrev <buffer> && and
iabbrev <buffer> \|\| or

" Requires pythonsense:
nmap <expr> <buffer> go (getline('.') =~# '^\s*def' ? '' : '[m') . 'yy]M] jpCdef<Tab>'
nmap <expr> <buffer> gO (getline('.') =~# '^\s*def' ? '' : '[m') . 'yy[ kPCdef<Tab>'

inoremap <buffer> """ """ """<C-g>U<Left><C-g>U<Left><C-g>U<Left>
inoremap <buffer> """<Cr> """<Cr>"""<esc>O

xnoremap <buffer> ik <Esc>?# %%.*\n\zs\\|\%^<Cr>V/\ze\n.*# %%\\|\%$<Cr>
omap <buffer> ik :normal vik<Cr>


" the first makes a["b"] ➜ a.b, the second does the opposite
nmap <buffer> \ga yiqva]p`[i.<Esc>e:silent! call repeat#set("\\ga")<Cr>
nmap <buffer> \gA ysiw"ysa"]X:silent!call repeat#set("\\gA")<Cr>
