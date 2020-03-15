nnoremap <buffer> <C-]> <C-]>
if exists(':helpclose')
  nnoremap <buffer> q :helpclose<CR>
else
  nnoremap <buffer> q :q<CR>
endif
if has('nvim')
  setlocal number relativenumber signcolumn=no
endif
