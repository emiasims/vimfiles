nnoremap <buffer> <C-]> <C-]>
if !&modifiable
  if exists(':helpclose')
    nnoremap <buffer> q :helpclose<CR>
  else
    nnoremap <buffer> q :q<CR>
  endif
endif
if has('nvim')
  setlocal number relativenumber signcolumn=no
endif
setlocal colorcolumn=80
