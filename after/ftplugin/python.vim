setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldminlines=2
setlocal colorcolumn=100
setlocal foldmethod=syntax
setlocal foldtext=fold#pythontext()
if has('nvim') && get(g:, 'loaded_nvim_treesitter', 0)
  setlocal foldmethod=expr
  setlocal foldexpr=v:lua.py_fold(v:lnum)
endif

command! -nargs=0 -buffer Outline lvimgrep /\v^\s*%(def |class )/ % | lopen

augroup vimrc_python
  autocmd!
  autocmd BufWritePre *.py %s/\s\+$//e
augroup END

nnoremap <silent> <buffer> \rq :call python#text_to_qf(python#get_repl_errortext()) \| cwin \| clast<Cr>

inoremap <buffer> ipdb __import__('ipdb').set_trace()<Esc>
inoremap <buffer> pdb __import__('pdb').set_trace()<Esc>
inoremap <buffer> iem __import__('IPython').embed()<Esc>

iabbrev <buffer> true True
iabbrev <buffer> false False
iabbrev <buffer> && and
iabbrev <buffer> \|\| or

" Requires pythonsense:
nmap <expr> <buffer> go (getline('.') =~# '^\s*def' ? '' : '[m') . 'yy]M] jpCdef<Tab>'
nmap <expr> <buffer> gO (getline('.') =~# '^\s*def' ? '' : '[m') . 'yy[ kPCdef<Tab>'

inoremap <buffer> """ """ """<C-g>U<Left><C-g>U<Left><C-g>U<Left>
inoremap <buffer> """<Cr> """<Cr>"""<esc>O
