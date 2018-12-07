setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal foldminlines=3
if executable('yapf')
  setlocal textwidth=0  " prevent auto formatting, yapfify will fail.
  setlocal formatprg=yapf
  setlocal formatexpr=yapf#yapfify(v:lnum,v:lnum+v:count-1)
endif

augroup vimrc_python
  autocmd!
  autocmd BufWritePre *.py %s/\s\+$//e
augroup END

" vim: set ts=2 sw=2 tw=99 et :
