setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldminlines=2
setlocal colorcolumn=100
setlocal foldmethod=syntax
setlocal foldtext=fold#pythontext()

nnoremap <buffer><silent> gO :lvimgrep /^\s*\%(def \|class \)/ %<CR>:lopen<CR>
nnoremap <buffer><silent> gO :lvimgrep /^\s*\%(def \\|class \)/ %<CR>:lopen<CR>

augroup vimrc_python
  autocmd!
  autocmd BufWritePre *.py %s/\s\+$//e
augroup END
