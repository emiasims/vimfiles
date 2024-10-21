nnoremap <buffer> K K
if !&modifiable
  if exists(':helpclose')
    nnoremap <buffer> q <cmd>helpclose<CR>
  else
    nnoremap <buffer> q :q<CR>
  endif
else
  setlocal concealcursor=
endif
if has('nvim')
  setlocal number relativenumber signcolumn=no
endif
setlocal colorcolumn=80
setlocal foldmethod=expr
