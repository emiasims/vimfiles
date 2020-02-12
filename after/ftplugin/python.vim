setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldminlines=2
setlocal colorcolumn=100
setlocal foldmethod=syntax
setlocal foldtext=fold#pythontext()

command! -nargs=0 -buffer Outline lvimgrep /\v^\s*%(def |class )/ % | lopen

augroup vimrc_python
  autocmd!
  autocmd BufWritePre *.py %s/\s\+$//e
augroup END

nmap <buffer> go [myy]M] jpCdef
nmap <buffer> gO [myy[ kPCdef

nnoremap <silent> <buffer> \rq :call python#text_to_qf(python#get_repl_errortext()) \| cwin \| cfirst<Cr>

command! -nargs=0 -buffer CocFormat call CocAction('format')

inoremap <buffer> ipdb __import__('ipdb').set_trace()<Esc>
inoremap <buffer> pdb __import__('pdb').set_trace()<Esc>
inoremap <buffer> iem __import__('IPython').embed()<Esc>
